import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:path/path.dart' as path;

enum EditMode { none, trim, insert }

class AudioToolViewModel extends BaseViewModel with Initialisable {
  AudioToolViewModel({required this.bookTitle, required this.audioPath});
  final String bookTitle;
  final String? audioPath;
  PlayerController? playerController;
  final NavigationService navigationService = NavigationService();
  final SnackbarService _snackbarService = SnackbarService();

  // Audio state
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isloading = true;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String currentAudioPath = '';

// Recorder state
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false;
  String? tempRecordingPath;
  // Waveform state
  double waveformPosition = 0.0;
  bool isDragging = false;

  // Edit state
  EditMode editMode = EditMode.none;
  bool isSelecting = false;
  double selectionStart = 0.0;
  double selectionWidth = 0.0;
  Duration selectionStartTime = Duration.zero;
  Duration selectionEndTime = Duration.zero;
  final List<String> undoStack = [];
  Timer? _recordingTimer;
  Duration _currentRecordingDuration = Duration.zero;
  Duration _maxAllowedRecordingDuration = Duration.zero;

  @override
  Future<void> initialise() async {
    if (audioPath != null) {
      await initializeAudioPlayer(audioPath!);
      await initializedWaveform();
      audioPlayer.positionStream.listen((pos) {
        position = pos;
        if (!isDragging) {
          waveformPosition = pos.inMilliseconds / duration.inMilliseconds;
          playerController?.seekTo(pos.inMilliseconds);
        }
        notifyListeners();
      });
    }
  }

  Future<void> startRecording() async {
    if (!isSelecting || editMode != EditMode.insert) return;

    // Calculate maximum allowed recording duration
    _maxAllowedRecordingDuration = selectionEndTime - selectionStartTime;

    final tempDir = await getTemporaryDirectory();
    tempRecordingPath =
        '${tempDir.path}/temp_insert_${DateTime.now().millisecondsSinceEpoch}.m4a';
    debugPrint('Recording path: $tempRecordingPath');

    try {
      if (await audioRecorder.hasPermission()) {
        await audioRecorder.start(
          const RecordConfig(
            numChannels: 2,
            sampleRate: 44100,
            bitRate: 128000,
            noiseSuppress: true,
          ),
          path: tempRecordingPath!,
        );

        isRecording = true;
        _currentRecordingDuration = Duration.zero;

        // Start timer to track recording duration
        _recordingTimer =
            Timer.periodic(const Duration(milliseconds: 100), (timer) async {
          _currentRecordingDuration += const Duration(milliseconds: 100);

          // Check if recording duration exceeds selection range
          if (_currentRecordingDuration >= _maxAllowedRecordingDuration) {
            timer.cancel();
            await stopRecording();
          }
          notifyListeners();
        });

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _snackbarService.showSnackbar(
        message: 'Failed to start recording',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;

    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final String? filePath = await audioRecorder.stop();
      isRecording = false;
      notifyListeners();

      if (filePath != null && tempRecordingPath != null) {
        // Only proceed with insertion if recording was successful
        if (await File(tempRecordingPath!).exists()) {
          final recordingDuration = await getAudioDuration(tempRecordingPath!);

          if (recordingDuration > _maxAllowedRecordingDuration) {
            // Trim the recording to match selection duration
            await _trimRecordingToFit(
                tempRecordingPath!, _maxAllowedRecordingDuration);
          }

          await insertAudioAtSelection(tempRecordingPath!);
        } else {
          _snackbarService.showSnackbar(
            message: 'Recording file not found',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _snackbarService.showSnackbar(
        message: 'Failed to stop recording',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _trimRecordingToFit(
      String recordingPath, Duration targetDuration) async {
    final tempDir = await getTemporaryDirectory();
    final trimmedPath =
        '${tempDir.path}/trimmed_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      final command =
          '-i "$recordingPath" -t ${targetDuration.inMilliseconds / 1000} -c copy "$trimmedPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // Replace original recording with trimmed version
        await File(trimmedPath).copy(recordingPath);
        await File(trimmedPath).delete();
      } else {
        throw Exception('Failed to trim recording');
      }
    } catch (e) {
      debugPrint('Error trimming recording: $e');
      throw Exception('Failed to trim recording: $e');
    }
  }

  Future<void> insertAudioAtSelection(String insertPath) async {
    //At first check if the selection is valid or not
    if (!isSelecting || selectionStartTime >= selectionEndTime) {
      _snackbarService.showSnackbar(
        message: 'Invalid selection for insertion',
        duration: const Duration(seconds: 2),
      );
      debugPrint('Invalid selection for insertion');
      return;
    }

    // Check if the insert audio file exists
    final tempDir = await getTemporaryDirectory();
    final tempOutputPath =
        '${tempDir.path}/temp_output_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final beforePath = '${tempDir.path}/before.m4a';
    final afterPath = '${tempDir.path}/after.m4a';

    try {
      setBusy(true);

      // Delete temp files if they exist
      for (final path in [tempOutputPath, beforePath, afterPath]) {
        // Delete file if it exists
        final file = File(path);
        // Check if the file exists
        if (await file.exists()) {
          // Delete the file
          await file.delete();
        }
      }

      // Get the duration of the insert audio
      final insertDuration = await getAudioDuration(insertPath);
      // Get the duration of the selection
      final selectionDuration = selectionEndTime - selectionStartTime;

      // Calculate the end time for after segment based on insert duration
      final afterStartTime = selectionStartTime + insertDuration;

      // This beforecommand is used to extract the audio before the selection
      final beforeCommand =
          '-i "$currentAudioPath" -t ${selectionStartTime.inMilliseconds / 1000} -c copy "$beforePath"';
      //this aftercommand is used to extract the audio after the selection
      final afterCommand =
          '-i "$currentAudioPath" -ss ${afterStartTime.inMilliseconds / 1000} -c copy "$afterPath"';

      //this beforeSession is used to execute the before command
      final beforeSession = await FFmpegKit.execute(beforeCommand);

      //Now check if the return code is success or not
      if (!ReturnCode.isSuccess(await beforeSession.getReturnCode())) {
        throw Exception('Failed to extract before segment');
      }
      //this afterSession is used to execute the after command
      final afterSession = await FFmpegKit.execute(afterCommand);
      if (!ReturnCode.isSuccess(await afterSession.getReturnCode())) {
        throw Exception('Failed to extract after segment');
      }

      //this is used to create a list of files to concatenate using concat demuxer in ffmpeg kit
      final listFile = File('${tempDir.path}/list.txt');
      //this is used to write the list of files to the list.txt file
      await listFile.writeAsString(
        //this is the list of files to concatenate
        "file '$beforePath'\nfile '$insertPath'\nfile '$afterPath'",
      );

      // Concatenate using concat demuxer
      final concatCommand = '''
      -f concat -safe 0 -i "${tempDir.path}/list.txt" 
      -c copy 
      "$tempOutputPath"
    '''
          .replaceAll('\n', ' ');

      //this concatsession is used to execute the concat command
      final concatSession = await FFmpegKit.execute(concatCommand);
      //this is used to check if the return code is success or not
      final returnCode = await concatSession.getReturnCode();
      //if the return code is success then stop the playback and clean up
      if (ReturnCode.isSuccess(returnCode)) {
        // Stop playback and clean up
        await audioPlayer.stop();
        await playerController?.stopPlayer();

        // Replace original file
        final originalFile = File(currentAudioPath);
        if (await originalFile.exists()) {
          await originalFile.delete();
        }
        await File(tempOutputPath).copy(currentAudioPath);

        // Clean up temp files
        for (final filePath in [
          beforePath,
          afterPath,
          tempOutputPath,
          listFile.path
        ]) {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        }

        // Clean up recording if it exists
        if (tempRecordingPath != null) {
          final recordingFile = File(tempRecordingPath!);
          if (await recordingFile.exists()) {
            await recordingFile.delete();
          }
          tempRecordingPath = null;
        }

        // Reload audio
        await _reloadAudio();
        setEditMode(EditMode.none);

        // Show appropriate message based on insert duration
        if (insertDuration > selectionDuration) {
          _snackbarService.showSnackbar(
            message: 'Audio inserted successfully (longer than selection)',
            duration: const Duration(seconds: 2),
          );
        } else {
          _snackbarService.showSnackbar(
            message: 'Audio inserted successfully',
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        throw Exception('Failed to concatenate audio segments');
      }
    } catch (e) {
      debugPrint('Error inserting audio: $e');
      _snackbarService.showSnackbar(
        message: 'Failed to insert audio: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<Duration> getAudioDuration(String audioPath) async {
    final session = await FFmpegKit.execute('-i "$audioPath" 2>&1');
    final output = await session.getOutput();

    if (output != null) {
      final durationRegex =
          RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})');
      final match = durationRegex.firstMatch(output);

      if (match != null) {
        return Duration(
          hours: int.parse(match.group(1) ?? '0'),
          minutes: int.parse(match.group(2) ?? '0'),
          seconds: int.parse(match.group(3) ?? '0'),
          milliseconds: (int.parse(match.group(4) ?? '0') * 10),
        );
      }
    }

    throw Exception('Could not determine audio duration');
  }

//initialize waveform
  Future<void> initializedWaveform() async {
    try {
      playerController = PlayerController();
      await playerController?.preparePlayer(
        path: audioPath!,
        shouldExtractWaveform: true,
        noOfSamples: 200,
        volume: 1.0,
      );
      playerController?.onCurrentDurationChanged.listen((duration) {
        if (!isDragging) {
          position = Duration(milliseconds: duration);
          notifyListeners();
        }
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error in initializedWaveform: $e');
    }
  }

  Future<void> initializeAudioPlayer(String audioPath) async {
    if (audioPath.isEmpty) {
      SnackbarService().showSnackbar(
        message: 'Audio path is empty',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    currentAudioPath = audioPath;
    undoStack.add(audioPath);
    setBusy(true);
    isloading = true;

    try {
      await audioPlayer.setFilePath(audioPath);
      duration = audioPlayer.duration ?? Duration.zero;
      //this is not working right now
      // if (duration == Duration.zero) {
      //   final session = await FFmpegKit.execute('-i "$audioPath" 2>&1');
      //   final output = await session.getOutput();

      //   if (output != null) {
      //     final durationRegex =
      //         RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})');
      //     final match = durationRegex.firstMatch(output);

      //     if (match != null) {
      //       duration = Duration(
      //         hours: int.parse(match.group(1) ?? '0'),
      //         minutes: int.parse(match.group(2) ?? '0'),
      //         seconds: int.parse(match.group(3) ?? '0'),
      //         milliseconds: (int.parse(match.group(4) ?? '0') * 10),
      //       );
      //     }
      //   }
      // }

      //
      audioPlayer.playerStateStream.listen(
        (state) {
          isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            isPlaying = false;
            position = duration;
            notifyListeners();
          }
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
      SnackbarService().showSnackbar(
        message: 'Error initializing audio player: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isloading = false;
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> playPause() async {
    try {
      if (audioPlayer.playerState.playing) {
        await audioPlayer.pause();
      } else {
        if (position >= duration ||
            duration - position < const Duration(milliseconds: 300)) {
          await audioPlayer.seek(Duration.zero);
          position = Duration.zero;
          notifyListeners();
        }
        await audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error in playPause: $e');
    }
  }

  void startSelection(double position) {
    if (editMode != EditMode.none) {
      isSelecting = true;
      selectionStart = position.clamp(0.0, 1.0);
      selectionWidth = 0; // Reset width when starting new selection
      debugPrint('Selection start: $selectionStart');
      selectionStartTime = Duration(
        milliseconds: (selectionStart * duration.inMilliseconds).round(),
      );
      // Seek to selection start position
      seek(selectionStartTime.inSeconds.toDouble());
      notifyListeners();
    }
  }

  void updateSelection(double position) {
    if (isSelecting) {
      double clampedPosition = position.clamp(0.0, 1.0);

      // Calculate the new width
      double newWidth = clampedPosition - selectionStart;

      // If dragging backwards
      if (newWidth < 0) {
        // Ensure minimum selection width of 0.01 (1% of total duration)
        if (newWidth.abs() < 0.01) {
          newWidth = -0.01;
        }
        selectionStart = clampedPosition;
        selectionWidth = -newWidth;
      } else {
        // Ensure minimum selection width of 0.01 (1% of total duration)
        if (newWidth < 0.01) {
          newWidth = 0.01;
        }
        selectionWidth = newWidth;
      }
      // Update selection times
      int startMs = (selectionStart * duration.inMilliseconds).round();
      debugPrint('StartMs: $startMs');
      int endMs =
          ((selectionStart + selectionWidth) * duration.inMilliseconds).round();
      debugPrint('EndMs: $endMs');

      selectionStartTime = Duration(milliseconds: startMs);
      debugPrint('Selection start time: $selectionStartTime');
      selectionEndTime = Duration(milliseconds: endMs);
      debugPrint('Selection end time: $selectionEndTime');
      debugPrint(
          'Selection times - Start: ${selectionStartTime.inSeconds}s, End: ${selectionEndTime.inSeconds}s');
      notifyListeners();
    }
  }

  void endSelection() {
    if (isSelecting) {
      if (selectionWidth < 0) {
        // Swap start and end times if selection was made backwards
        final temp = selectionStartTime;
        selectionStartTime = selectionEndTime;
        selectionEndTime = temp;

        // Update visual selection
        selectionStart = selectionStart;
        selectionWidth = selectionWidth.abs();
      }

      // Ensure minimum selection duration of 100ms
      if (selectionEndTime.inMilliseconds - selectionStartTime.inMilliseconds <
          100) {
        selectionEndTime =
            selectionStartTime + const Duration(milliseconds: 100);
        selectionWidth = (selectionEndTime.inMilliseconds -
                selectionStartTime.inMilliseconds) /
            duration.inMilliseconds;
      }

      debugPrint(
          'Final selection - Start: ${selectionStartTime.inSeconds}s, End: ${selectionEndTime.inSeconds}s');
      notifyListeners();
    }
  }

  Future<void> trimAudio(String outputPath) async {
    try {
      if (selectionStartTime >= selectionEndTime) {
        _snackbarService.showSnackbar(
          message: 'Invalid selection: Start must be before end',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      if (selectionStartTime < Duration.zero || selectionEndTime > duration) {
        _snackbarService.showSnackbar(
          message: 'Invalid selection: Out of audio bounds',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Store time frame information before trim
      final trimStartStr = formatDuration(selectionStartTime);
      final trimEndStr = formatDuration(selectionEndTime);
      final trimDurationStr =
          formatDuration(selectionEndTime - selectionStartTime);

      final tempDir = await getTemporaryDirectory();
      final tempOutputPath = path.join(tempDir.path,
          'temp_trim_${DateTime.now().millisecondsSinceEpoch}.m4a');
      final tempBackupPath = path.join(
          tempDir.path, 'backup_${DateTime.now().millisecondsSinceEpoch}.m4a');

      final startSeconds = selectionStartTime.inMilliseconds / 1000;
      final durationSeconds =
          (selectionEndTime - selectionStartTime).inMilliseconds / 1000;

      final command =
          '-i "$currentAudioPath" -ss $startSeconds -t $durationSeconds '
          '-c:a aac -b:a 128k "$tempOutputPath"';

      setBusy(true);

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        await audioPlayer.stop();
        await playerController?.stopPlayer();

        try {
          await File(currentAudioPath).copy(tempBackupPath);

          final trimmedFile = File(tempOutputPath);
          if (!await trimmedFile.exists() || await trimmedFile.length() == 0) {
            throw Exception('Trimmed file is invalid or empty');
          }

          await trimmedFile.copy(currentAudioPath);

          if (await trimmedFile.exists()) await trimmedFile.delete();
          final backupFile = File(tempBackupPath);
          if (await backupFile.exists()) await backupFile.delete();

          await _reloadAudio();
          setEditMode(EditMode.none);
          // Show success message with time frame information
          _snackbarService.showSnackbar(
            message: 'Audio trimmed successfully\n'
                'From: $trimStartStr\n'
                'To: $trimEndStr\n'
                'Duration: $trimDurationStr',
            duration: const Duration(seconds: 4),
          );
        } catch (e) {
          final backupFile = File(tempBackupPath);
          if (await backupFile.exists()) {
            await backupFile.copy(currentAudioPath);
            await backupFile.delete();
          }
          throw Exception('Failed to replace audio file: $e');
        }
      } else {
        final logs = await session.getLogs();
        throw Exception('FFmpeg failed: ${logs.join("\n")}');
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Failed to trim audio: $e',
        duration: const Duration(seconds: 2),
      );
      debugPrint('Error trimming audio: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> _reloadAudio() async {
    try {
      await audioPlayer.stop();
      await playerController?.stopPlayer();

      await initializeAudioPlayer(currentAudioPath);
      await initializedWaveform();
    } catch (e) {
      debugPrint('Error reloading audio: $e');
      _snackbarService.showSnackbar(
        message: 'Error reloading audio: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> seek(double seconds) async {
    if (seconds >= 0 && seconds <= duration.inSeconds) {
      try {
        await audioPlayer.seek(Duration(seconds: seconds.toInt()));
        position = Duration(seconds: seconds.toInt());
        if (seconds >= duration.inSeconds) {
          isPlaying = false;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error in seek: $e');
      }
    }
  }

  void setEditMode(EditMode mode) {
    editMode = mode;
    isSelecting = mode != EditMode.none;
    if (!isSelecting) {
      selectionStartTime = Duration.zero;
      selectionEndTime = Duration.zero;
      selectionStart = 0.0;
      selectionWidth = 0.0;
    }
    notifyListeners();
  }

  Future<void> applyChanges() async {
    if (!isSelecting) return;
    setBusy(true);
    try {
      switch (editMode) {
        case EditMode.trim:
          await trimAudio(currentAudioPath);
          break;
        case EditMode.insert:
          await insertAudioAtSelection(tempRecordingPath!);
          break;
        default:
          return;
      }
    } catch (e) {
      debugPrint('Error applying changes: $e');
      _snackbarService.showSnackbar(
        message: 'Failed to apply changes: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

//delete audio and navigate back also show snackbar
  void deleteAudio() async {
    final file = File(currentAudioPath);
    if (await file.exists()) {
      await file.delete();
    }
    navigationService.back();
    _snackbarService.showSnackbar(
      message: 'Audio deleted successfully',
      duration: const Duration(seconds: 2),
    );
  }

//format duration
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds =
        twoDigits(duration.inMilliseconds.remainder(100));

    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds.$twoDigitMilliseconds";
  }

//set manual time range
  void setManualTimeRange(Duration startTime, Duration endTime) {
    if (!isSelecting || editMode == EditMode.none) return;
    // Validate time range
    if (startTime >= endTime ||
        startTime < Duration.zero ||
        endTime > duration) {
      _snackbarService.showSnackbar(
        message: 'Invalid time range',
        duration: const Duration(seconds: 2),
      );
      return;
    }
    // Update selection times
    selectionStartTime = startTime;
    selectionEndTime = endTime;
    // Update visual selection
    selectionStart = startTime.inMilliseconds / duration.inMilliseconds;
    selectionWidth = (endTime.inMilliseconds - startTime.inMilliseconds) /
        duration.inMilliseconds;
    debugPrint(
        'Manual selection set - Start: ${startTime.inSeconds}s, End: ${endTime.inSeconds}s');
    debugPrint(
        'Selection visuals - Start: $selectionStart, Width: $selectionWidth');
    notifyListeners();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    playerController?.dispose();
    audioRecorder.dispose();
    super.dispose();
  }
}

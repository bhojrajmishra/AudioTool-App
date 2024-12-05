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
  //this is not working ayela
  final List<String> undoStack = [];
  Timer? _recordingTimer;
  Duration _currentRecordingDuration = Duration.zero;
  Duration _maxAllowedRecordingDuration = Duration.zero;

  //preview
  String? previewPath;
  bool isPreviewReady = false;
  bool isPreviewPlaying = false;
  final AudioPlayer previewPlayer = AudioPlayer();
  Duration previewDuration = Duration.zero;
  Duration previewPosition = Duration.zero;

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
      _snackbarService.closeSnackbar();
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
        if (await File(tempRecordingPath!).exists()) {
          final recordingDuration = await _getAudioDuration(tempRecordingPath!);

          if (recordingDuration > _maxAllowedRecordingDuration) {
            await _trimRecordingToFit(
                tempRecordingPath!, _maxAllowedRecordingDuration);
          }

          // Instead of inserting immediately, prepare preview
          // await preparePreview(tempRecordingPath!);
        } else {
          _snackbarService.closeSnackbar();
          _snackbarService.showSnackbar(
            message: 'Recording file not found',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _snackbarService.closeSnackbar();
      _snackbarService.showSnackbar(
        message: 'Failed to stop recording',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Future<void> preparePreview(String recordingPath) async {
  //   try {
  //     final tempDir = await getTemporaryDirectory();
  //     previewPath =
  //         '${tempDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.m4a';

  //     // Create preview by combining segments
  //     final beforePath = '${tempDir.path}/preview_before.m4a';
  //     final afterPath = '${tempDir.path}/preview_after.m4a';

  //     // Extract before segment
  //     final beforeCommand =
  //         '-i "$currentAudioPath" -t ${selectionStartTime.inMilliseconds / 1000} -c copy "$beforePath"';

  //     final beforeSession = await FFmpegKit.execute(beforeCommand);
  //     if (!ReturnCode.isSuccess(await beforeSession.getReturnCode())) {
  //       throw Exception('Failed to extract before segment for preview');
  //     }

  //     // Extract after segment
  //     final afterStartTime =
  //         selectionStartTime + await _getAudioDuration(recordingPath);
  //     final afterCommand =
  //         '-i "$currentAudioPath" -ss ${afterStartTime.inMilliseconds / 1000} -c copy "$afterPath"';

  //     final afterSession = await FFmpegKit.execute(afterCommand);
  //     if (!ReturnCode.isSuccess(await afterSession.getReturnCode())) {
  //       throw Exception('Failed to extract after segment for preview');
  //     }

  //     // Create concatenation list
  //     final listFile = File('${tempDir.path}/preview_list.txt');
  //     await listFile.writeAsString(
  //       "file '$beforePath'\nfile '$recordingPath'\nfile '$afterPath'",
  //     );

  //     // Concatenate segments
  //     final concatCommand =
  //         '-f concat -safe 0 -i "${listFile.path}" -c copy "$previewPath"';

  //     final concatSession = await FFmpegKit.execute(concatCommand);
  //     if (!ReturnCode.isSuccess(await concatSession.getReturnCode())) {
  //       throw Exception('Failed to create preview');
  //     }

  //     // Initialize preview player
  //     await previewPlayer.setFilePath(previewPath!);
  //     previewDuration = previewPlayer.duration ?? Duration.zero;
  //     isPreviewReady = true;

  //     // Clean up temporary files
  //     for (final path in [beforePath, afterPath, listFile.path]) {
  //       final file = File(path);
  //       if (await file.exists()) {
  //         await file.delete();
  //       }
  //     }

  //     notifyListeners();
  //     _snackbarService.closeSnackbar();
  //     _snackbarService.showSnackbar(
  //       message: 'Preview ready. Press play to listen.',
  //       duration: const Duration(seconds: 2),
  //     );
  //   } catch (e) {
  //     debugPrint('Error preparing preview: $e');
  //     _snackbarService.closeSnackbar();
  //     _snackbarService.showSnackbar(
  //       message: 'Failed to prepare preview: $e',
  //       duration: const Duration(seconds: 2),
  //     );
  //   }
  // }

  Future<void> togglePreview() async {
    if (!isPreviewReady) return;

    try {
      if (previewPlayer.playing) {
        await previewPlayer.pause();
        isPreviewPlaying = false;
      } else {
        await previewPlayer.play();
        isPreviewPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling preview: $e');
      _snackbarService.closeSnackbar();
      _snackbarService.showSnackbar(
        message: 'Failed to play preview',
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
      _snackbarService.closeSnackbar();
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
      final insertDuration = await _getAudioDuration(insertPath);
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
          _snackbarService.closeSnackbar();
          _snackbarService.showSnackbar(
            message: 'Audio inserted successfully (longer than selection)',
            duration: const Duration(seconds: 2),
          );
        } else {
          _snackbarService.closeSnackbar();
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
      _snackbarService.closeSnackbar();
      _snackbarService.showSnackbar(
        message: 'Failed to insert audio: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<Duration> _getAudioDuration(String audioPath) async {
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
      _snackbarService.closeSnackbar();
      _snackbarService.showSnackbar(
        message: 'No audio file found',
        duration: const Duration(seconds: 2),
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
      _snackbarService.closeSnackbar();
      _snackbarService.showSnackbar(
        message: 'Failed to load audio: $e',
        duration: const Duration(seconds: 2),
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
        //this is used to check if the position is greater than the duration or the duration minus the position is less than 300 milliseconds
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

  Future<void> _reloadAudio() async {
    try {
      await audioPlayer.stop();
      await playerController?.stopPlayer();
      await initializeAudioPlayer(currentAudioPath);
      await initializedWaveform();
    } catch (e) {
      debugPrint('Error reloading audio: $e');
      _snackbarService.closeSnackbar();
      _snackbarService.showSnackbar(
        message: 'Error reloading audio: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> trimAudio(String outputPath) async {
    try {
      if (selectionStartTime >= selectionEndTime) {
        _snackbarService.closeSnackbar();
        _snackbarService.showSnackbar(
          message: 'Invalid selection: Start must be before end',
          duration: const Duration(seconds: 2),
        );
        return;
      }
      if (selectionStartTime < Duration.zero || selectionEndTime > duration) {
        _snackbarService.closeSnackbar();
        _snackbarService.showSnackbar(
          message: 'Invalid selection: Out of audio bounds',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      //here we are formatting the duration of the selection start time and the selection end time and the duration of the selection end time minus the selection start time
      final trimStartStr = formatDuration(selectionStartTime);
      final trimEndStr = formatDuration(selectionEndTime);
      final trimDurationStr =
          formatDuration(selectionEndTime - selectionStartTime);

      //here we are creating a temporary directory for the output path and tempOutputPath for the temporary output path and tempBackupPath for the temporary backup path this temp is used to store the temporary files that are created during the trimming process this is necessary in trimming the aduio inorder to avoid any data loss or corruption of the original audio file
      final tempDir = await getTemporaryDirectory();
      final tempOutputPath = path.join(tempDir.path,
          'temp_trim_${DateTime.now().millisecondsSinceEpoch}.m4a');
      final tempBackupPath = path.join(
          tempDir.path, 'backup_${DateTime.now().millisecondsSinceEpoch}.m4a');

      //here beforePath is used to store the path of the audio file before the selection and afterPath is used to store the path of the audio file after the selection it is used to store the audio file after the selection
      final beforePath = path.join(
          tempDir.path, 'before_${DateTime.now().millisecondsSinceEpoch}.m4a');
      final afterPath = path.join(
          tempDir.path, 'after_${DateTime.now().millisecondsSinceEpoch}.m4a');

      setBusy(true);

      // Extract before selection
      if (selectionStartTime > Duration.zero) {
        final beforeCommand =
            '-i "$currentAudioPath" -t ${selectionStartTime.inMicroseconds / 1000000} -c copy "$beforePath"';
        final beforeSession = await FFmpegKit.execute(beforeCommand);
        if (!ReturnCode.isSuccess(await beforeSession.getReturnCode())) {
          throw Exception('Failed to extract before segment');
        }
      }

      // here if statement is used to check if the selection end time is less than the duration of the audio file
      if (selectionEndTime < duration) {
        final afterCommand =
            '-i "$currentAudioPath" -ss ${selectionEndTime.inMicroseconds / 1000000} -c copy "$afterPath"';
        final afterSession = await FFmpegKit.execute(afterCommand);
        if (!ReturnCode.isSuccess(await afterSession.getReturnCode())) {
          throw Exception('Failed to extract after segment');
        }
      }

      // Create a list of files to concatenate using concat demuxer in FFmpeg
      final listFile = File('${tempDir.path}/list.txt');
      String listContent = '';

      if (await File(beforePath).exists()) {
        listContent += "file '$beforePath'\n";
      }
      if (await File(afterPath).exists()) {
        listContent += "file '$afterPath'\n";
      }
      // Write the list of files to the list file
      await listFile.writeAsString(listContent);

      //this concatcommand have -f means concat demuxer  -safe 0 means to allow unsafe file names and -i is used to specify the input file -c copy is used to copy the codecs
      final concatCommand =
          '-f concat -safe 0 -i "${listFile.path}" -c copy "$tempOutputPath"';

      //here session is used to execute the concat command and return the return code
      final session = await FFmpegKit.execute(concatCommand);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        await audioPlayer.stop();
        await playerController?.stopPlayer();

        try {
          // Backup current file
          await File(currentAudioPath).copy(tempBackupPath);

          final trimmedFile = File(tempOutputPath);
          if (!await trimmedFile.exists() || await trimmedFile.length() == 0) {
            throw Exception('Trimmed file is invalid or empty');
          }
          // Replace original file
          await trimmedFile.copy(currentAudioPath);
          // Cleanup temporary files
          for (final filePath in [
            tempOutputPath,
            beforePath,
            afterPath,
            listFile.path
          ]) {
            final file = File(filePath);
            if (await file.exists()) {
              await file.delete();
            }
          }

          await _reloadAudio();
          setEditMode(EditMode.none);
          _snackbarService.closeSnackbar();
          _snackbarService.showSnackbar(
            message: 'Audio trimmed successfully\n'
                'From: $trimStartStr\n'
                'To: $trimEndStr\n'
                'Duration: $trimDurationStr',
            duration: const Duration(seconds: 4),
          );
        } catch (e) {
          // Restore from backup if operation fails
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
      _snackbarService.closeSnackbar();
      _snackbarService.showSnackbar(
        message: 'Failed to trim audio: $e',
        duration: const Duration(seconds: 2),
      );
      debugPrint('Error trimming audio: $e');
    } finally {
      setBusy(false);
    }
  }

//it is used in progress bar
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
          if (tempRecordingPath != null &&
              await File(tempRecordingPath!).exists()) {
            await insertAudioAtSelection(tempRecordingPath!);
          } else {
            throw Exception('No recording available to insert');
          }
          break;
        default:
          return;
      }

      // Clean up preview
      await cleanupPreview();
    } catch (e) {
      debugPrint('Error applying changes: $e');
      _snackbarService.closeSnackbar();
      _snackbarService.showSnackbar(
        message: 'Failed to apply changes: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> cleanupPreview() async {
    try {
      await previewPlayer.stop();
      await previewPlayer.dispose();

      if (previewPath != null) {
        final previewFile = File(previewPath!);
        if (await previewFile.exists()) {
          await previewFile.delete();
        }
      }
      isPreviewReady = false;
      isPreviewPlaying = false;
      previewPath = null;
      previewDuration = Duration.zero;
      previewPosition = Duration.zero;

      notifyListeners();
    } catch (e) {
      debugPrint('Error cleaning up preview: $e');
    }
  }

//delete audio and navigate back also show snackbar
  void deleteAudio() async {
    final file = File(currentAudioPath);
    if (await file.exists()) {
      await file.delete();
    }
    navigationService.back();
    _snackbarService.closeSnackbar();
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

    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    playerController?.dispose();
    audioRecorder.dispose();
    cleanupPreview();
    super.dispose();
  }
}

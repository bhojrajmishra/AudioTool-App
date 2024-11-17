import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:path/path.dart' as path;

enum EditMode { none, trim, insert }

class AudioToolViewModel extends BaseViewModel with Initialisable {
  AudioToolViewModel({required this.bookTitle, required this.audioPath});

  final String bookTitle;
  final String? audioPath;
  PlayerController? playerController;

  // Audio state
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isloading = true;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String currentAudioPath = '';
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

      if (duration == Duration.zero) {
        final session = await FFmpegKit.execute('-i "$audioPath" 2>&1');
        final output = await session.getOutput();

        if (output != null) {
          final durationRegex =
              RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})');
          final match = durationRegex.firstMatch(output);

          if (match != null) {
            duration = Duration(
              hours: int.parse(match.group(1) ?? '0'),
              minutes: int.parse(match.group(2) ?? '0'),
              seconds: int.parse(match.group(3) ?? '0'),
              milliseconds: (int.parse(match.group(4) ?? '0') * 10),
            );
          }
        }
      }

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
      int endMs =
          ((selectionStart + selectionWidth) * duration.inMilliseconds).round();

      selectionStartTime = Duration(milliseconds: startMs);
      selectionEndTime = Duration(milliseconds: endMs);

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
    debugPrint('Starting trim operation...');
    debugPrint('Selection start time: ${selectionStartTime.inSeconds}s');
    debugPrint('Selection end time: ${selectionEndTime.inSeconds}s');
    debugPrint('Total duration: ${duration.inSeconds}s');
    debugPrint('Original audio path: $currentAudioPath');

    if (selectionStartTime >= selectionEndTime) {
      debugPrint('Invalid selection: Start time >= End time');
      SnackbarService().showSnackbar(
        message: 'Invalid selection range: Start must be before end',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (selectionStartTime < Duration.zero || selectionEndTime > duration) {
      debugPrint('Invalid selection: Outside of audio bounds');
      SnackbarService().showSnackbar(
        message: 'Invalid selection range: Selection outside audio bounds',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final startSeconds = selectionStartTime.inMilliseconds / 1000;
    final durationSeconds =
        (selectionEndTime - selectionStartTime).inMilliseconds / 1000;

    // Create a temporary file with proper extension
    final originalExt = path.extension(currentAudioPath);
    final tempDir = await getTemporaryDirectory();
    final tempFileName =
        'temp_trim_${DateTime.now().millisecondsSinceEpoch}$originalExt';
    final tempOutputPath = path.join(tempDir.path, tempFileName);

    debugPrint('Temp output path: $tempOutputPath');

    // Ensure proper file extension and quotes for paths
    final command =
        '-i "$currentAudioPath" -ss $startSeconds -t $durationSeconds -c copy "$tempOutputPath"';
    debugPrint('FFmpeg command: $command');

    try {
      setBusy(true);

      // Execute trim command
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      final logs = await session.getLogs();

      debugPrint('FFmpeg logs:');
      for (final log in logs) {
        debugPrint(log.getMessage());
      }

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('Trim successful, replacing original file');

        // Stop playback and release the file
        await audioPlayer.stop();
        await playerController?.stopPlayer();

        try {
          // Delete the original file
          final originalFile = File(currentAudioPath);
          if (await originalFile.exists()) {
            await originalFile.delete();
            debugPrint('Original file deleted successfully');
          }

          // Move temp file to original location
          final tempFile = File(tempOutputPath);
          await tempFile.copy(currentAudioPath);
          await tempFile.delete(); // Clean up temp file after copying
          debugPrint('Audio file replaced successfully');

          // Reload the audio with the same path
          await _reloadAudio();
          setEditMode(EditMode.none);

          SnackbarService().showSnackbar(
            message: 'Audio trimmed successfully',
            duration: const Duration(seconds: 2),
          );
        } catch (e) {
          debugPrint('Error handling files: $e');
          throw Exception('Failed to replace original file: $e');
        }
      } else {
        debugPrint('FFmpeg failed with return code: ${returnCode?.getValue()}');
        throw Exception(
            'Failed to trim audio: Return code ${returnCode?.getValue()}');
      }
    } catch (e) {
      debugPrint('Error trimming audio: $e');
      SnackbarService().showSnackbar(
        message: 'Failed to trim audio: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      // Clean up temp file if it exists
      try {
        final tempFile = File(tempOutputPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
          debugPrint('Temp file cleaned up');
        }
      } catch (e) {
        debugPrint('Error cleaning up temp file: $e');
      }

      setBusy(false);
    }
  }

  Future<void> _reloadAudio() async {
    await audioPlayer.stop();
    await initializeAudioPlayer(currentAudioPath);
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
          break;
        default:
          return;
      }
    } catch (e) {
      debugPrint('Error applying changes: $e');
      SnackbarService().showSnackbar(
        message: 'Failed to apply changes: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  void setManualTimeRange(Duration startTime, Duration endTime) {
    if (!isSelecting || editMode == EditMode.none) return;

    // Validate time range
    if (startTime >= endTime ||
        startTime < Duration.zero ||
        endTime > duration) {
      SnackbarService().showSnackbar(
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
    super.dispose();
  }
}

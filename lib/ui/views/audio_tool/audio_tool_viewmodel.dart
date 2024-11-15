import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

enum EditMode { none, trim, insert }

class AudioToolViewModel extends BaseViewModel with Initialisable {
  AudioToolViewModel({required this.bookTitle, required this.audioPath});

  final String bookTitle;
  final String? audioPath;
  PlayerController? playerController;
  @override
  Future<void> initialise() async {
    await initializedWaveform();
    await initializeAudioPlayer(audioPath!);
    audioPlayer.positionStream.listen((pos) {
      position = pos;
      if (isDragging) {
        waveformPosition = pos.inMilliseconds / duration.inMilliseconds;
        playerController?.seekTo(pos.inMilliseconds);
      }
      notifyListeners();
    });
  }

  //Initialize the audio player
  final AudioPlayer audioPlayer = AudioPlayer();
  //bool to check if the audio is playing or not
  bool isPlaying = false, isloading = true;
  //Duration of the audio and the current position of the audio
  Duration duration = Duration.zero;
  //Duration of the audio and the current position of the audio
  Duration position = Duration.zero;
  //String to store the current audio path

  //waveform state
  double waveformPosition = 0.0;
  bool isDragging = false;

  //Editing state
  EditMode editMode = EditMode.none;
  bool isSelecting = false;
  double selectionStart = 0.0;
  double selectionWidth = 0.0;
  Duration selectionStartTime = Duration.zero;
  Duration selectionEndTime = Duration.zero;
  String currentAudioPath = '';
  //List to store the undo stack but its not used now but can be used in the future
  final List<String> undoStack = [];

  //this function will be used to initialize the waveform
  Future<void> initializedWaveform() async {
    try {
      // Initialize the player controller
      playerController = PlayerController();
      await playerController?.preparePlayer(
        path: audioPath!,
        shouldExtractWaveform: true,
        noOfSamples: 100,
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

  //this function will be used to initialize the audio player
  Future<void> initializeAudioPlayer(String audioPath) async {
    if (audioPath.isEmpty) {
      SnackbarService().showSnackbar(
        message: 'Audio path is empty',
        duration: const Duration(seconds: 3),
      );
      debugPrint('Error: Audio path is empty');
      return;
    }
    currentAudioPath = audioPath;
    undoStack.add(audioPath);
    setBusy(true);
    isloading = true;

    try {
      // First try to set up the audio player
      await audioPlayer.setFilePath(audioPath);

      // Get duration directly from the audio player
      duration = audioPlayer.duration ?? Duration.zero;

      // If duration is zero, try using FFmpeg as fallback
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

      // Set up position stream listener
      audioPlayer.positionStream.listen(
        (pos) {
          position = pos;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Position stream error: $error');
        },
      );
      // Set up player state stream listener
      audioPlayer.playerStateStream.listen(
        (state) {
          isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            isPlaying = false;
            position =
                duration; // Explicitly set position to duration when completed
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

  // this is the function that will be called when the play button is pressed
  Future<void> playPause() async {
    try {
      if (audioPlayer.playerState.playing) {
        await audioPlayer.pause();
      } else {
        // Check if we're at or near the end
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
    if (editMode == EditMode.none) {
      isSelecting = true;
      selectionStart = position;
      selectionStartTime =
          Duration(milliseconds: (position * duration.inMilliseconds).round());
      debugPrint('Selection start: $selectionStartTime');
    }
  }

  void updateSelection(double position) {
    if (isSelecting) {
      selectionWidth = position - selectionStart;
      selectionEndTime = Duration(
        milliseconds: (position * duration.inMilliseconds).round(),
      );
      debugPrint('Selection end: $selectionEndTime');
      notifyListeners();
    }
  }

  void endSelection(double position) {
    if (isSelecting) {
      if (selectionStartTime > selectionEndTime) {
        final temp = selectionStartTime;
        selectionStartTime = selectionEndTime;
        selectionEndTime = temp;
      }
      notifyListeners();
    }
  }

  // this is the function that will be called when the seek button is pressed
  Future<void> trimAudio(String outputPath) async {
    if (selectionStartTime >= selectionEndTime) {
      SnackbarService().showSnackbar(
        message: 'Invalid selection range',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final startSeconds = selectionStartTime.inMilliseconds / 1000;
    final duration =
        (selectionEndTime - selectionStartTime).inMilliseconds / 1000;
//this command take start time and duration and output path and trim the audio
    final command =
        '-i "$currentAudioPath" -ss $startSeconds -t $duration -c copy "$outputPath"';
//this will execute the command
    try {
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        undoStack.add(currentAudioPath);
        currentAudioPath = outputPath;
        await _reloadAudio();
        setEditMode(EditMode.none);
      } else {
        final logs = await session.getAllLogs();
        debugPrint('Error trimming audio: $logs');
        throw Exception('Error trimming audio');
      }
    } catch (e) {
      debugPrint('Error in trimAudio: $e');
    }
  }

  Future<void> _reloadAudio() async {
    await audioPlayer.stop();
    await initializeAudioPlayer(currentAudioPath);
  }

  void setEditMode(EditMode mode) {
    editMode = mode;
    isSelecting = mode != EditMode.none;
    if (!isSelecting) {
      selectionStartTime = Duration.zero;
      debugPrint('Selection start here: $selectionStart');
      selectionEndTime = Duration.zero;
      debugPrint('Selection end here: $selectionWidth');
    }
    notifyListeners();
    debugPrint('Edit mode: $editMode');
  }

  Future<void> applyChanges() async {
    if (!isSelecting) return;
    setBusy(true);
    try {
      final currentPath = audioPath;
      final outputPath =
          '$currentPath/edited_${DateTime.now().millisecondsSinceEpoch}.m4a';
      debugPrint('Output path: $outputPath');
      switch (editMode) {
        case EditMode.trim:
          await trimAudio(outputPath);
          debugPrint('Trimming audio');
          break;
        case EditMode.insert:
          // await insertAudio(outputPath);
          break;
        default:
          return;
      }
    } catch (e) {
      debugPrint('Error applying changes: $e');
    } finally {
      setBusy(false);
    }
  }

  // this is the function that will be called when the seek button is pressed
  Future<void> seek(double seconds) async {
    if (seconds >= 0 && seconds <= duration.inSeconds) {
      try {
        await audioPlayer.seek(Duration(seconds: seconds.toInt()));
        debugPrint('Seeking to $seconds');
        position = Duration(seconds: seconds.toInt());
        debugPrint('Position: $position');
        // If we're at the end and seeking, make sure play button shows
        if (seconds >= duration.inSeconds) {
          isPlaying = false;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error in seek: $e');
      }
    }
  }

//this function will be used to delete the audio
  Future<void> deleteAudio() async {
    try {
      await audioPlayer.stop();
      await audioPlayer.dispose();
      await File(currentAudioPath).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting audio: $e');
    }
    debugPrint('Audio deleted');
  }

  //this formatDuration function will be used to format the duration of the audio
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    debugPrint('Audio player disposed');
    playerController?.dispose();
    debugPrint('Player controller disposed');
    super.dispose();
  }
}

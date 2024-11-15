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
      selectionStart = position;
      debugPrint('Selection start: $selectionStart');
      selectionStartTime = Duration(
        milliseconds: (position * duration.inMilliseconds).round(),
      );
      notifyListeners();
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

  void endSelection() {
    if (isSelecting) {
      if (selectionStartTime > selectionEndTime) {
        final temp = selectionStartTime;
        selectionStartTime = selectionEndTime;
        selectionEndTime = temp;
      }
      notifyListeners();
    }
  }

  Future<void> trimAudio(String outputPath) async {
    if (selectionStartTime >= selectionEndTime) {
      SnackbarService().showSnackbar(
        message: 'Invalid selection range',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final startSeconds = selectionStartTime.inMilliseconds / 1000;
    debugPrint('Start seconds: $startSeconds');
    final duration =
        (selectionEndTime - selectionStartTime).inMilliseconds / 1000;
    debugPrint('Duration: $duration');

    final command =
        '-i "$currentAudioPath" -ss $startSeconds -t $duration -c copy "$outputPath"';

    try {
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        undoStack.add(currentAudioPath);
        currentAudioPath = outputPath;
        await _reloadAudio();
        setEditMode(EditMode.none);
      } else {
        final logs = await session.getLogs();
        debugPrint('FFmpeg error logs: $logs');
        throw Exception('Failed to trim audio');
      }
    } catch (e) {
      debugPrint('Error trimming audio: $e');
      SnackbarService().showSnackbar(
        message: 'Failed to trim audio: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
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
      debugPrint('Selection start time: $selectionStartTime');
      selectionEndTime = Duration.zero;
      debugPrint('Selection end time: $selectionEndTime');
      selectionStart = 0.0;

      selectionWidth = 0.0;
    }
    notifyListeners();
  }

  Future<void> applyChanges() async {
    if (!isSelecting) return;
    setBusy(true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final outputPath =
          '${directory.path}/edited_${DateTime.now().millisecondsSinceEpoch}.m4a';

      switch (editMode) {
        case EditMode.trim:
          await trimAudio(outputPath);
          break;
        case EditMode.insert:
          // Implement insert functionality if needed
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

  Future<void> deleteAudio() async {
    try {
      await audioPlayer.stop();
      await audioPlayer.dispose();
      await File(currentAudioPath).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting audio: $e');
    }
  }

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
    super.dispose();
  }
}

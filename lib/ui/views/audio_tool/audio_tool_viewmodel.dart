import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AudioToolViewModel extends BaseViewModel with Initialisable {
  AudioToolViewModel({required this.bookTitle, required this.audioPath});

  final String bookTitle;
  final String? audioPath;
  PlayerController? playerController;

  @override
  void initialise() {
    if (audioPath != null) {
      initializeAudioPlayer(audioPath!);
      initializedWaveform();
    }
  }

  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false, isloading = true;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String? currentAudioPath;
  final List<String> undoStack = [];

  Future<void> initializedWaveform() async {
    try {
      playerController = PlayerController();
      await playerController?.preparePlayer(
        path: audioPath!,
        shouldExtractWaveform: true,
        noOfSamples: 100,
        volume: 1.0,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error in initializedWaveform: $e');
    }
  }

  Future<void> initializeAudioPlayer(String audioPath) async {
    if (audioPath.isEmpty) {
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
      duration = await audioPlayer.duration ?? Duration.zero;

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
        onError: (error) {
          debugPrint('Player state stream error: $error');
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

  Future<void> seek(double seconds) async {
    if (seconds >= 0 && seconds <= duration.inSeconds) {
      try {
        await audioPlayer.seek(Duration(seconds: seconds.toInt()));
        position = Duration(seconds: seconds.toInt());
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

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}

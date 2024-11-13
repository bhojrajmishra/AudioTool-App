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

  @override
  void initialise() {
    if (audioPath != null) {
      initializeAudioPlayer(audioPath!);
      initializedWaveform();
    }
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
  String currentAudioPath = '';
  //List to store the undo stack but its not used now but can be used in the future
  final List<String> undoStack = [];

  //Editing state
  EditMode editMode = EditMode.none;
  bool isSelecting = false;
  double selectionStart = 0.0;
  double selectionEnd = 0.0;
  Duration selectionStartTime = Duration.zero;
  Duration selectionEndTime = Duration.zero;
  String currentOutputPath = '';
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
      notifyListeners();
    } catch (e) {
      debugPrint('Error in initializedWaveform: $e');
    }
  }

  //this function will be used to initialize the audio player
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
      duration = audioPlayer.duration ?? Duration.zero;

      // If duration is zero, try using FFmpeg as fallback
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

  // this is the function that will be called when the seek button is pressed
  Future<void> trimAudio(String outputPath) async {
    final startSeconds = selectionStartTime.inMilliseconds / 1000;
    debugPrint('Start seconds: $startSeconds');
    final duration =
        (selectionEndTime - selectionStartTime).inMilliseconds / 1000;
    debugPrint('Duration: $duration');

    final command =
        '-i "$currentAudioPath" -ss $startSeconds -t $duration -c copy "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      undoStack.add(currentAudioPath);
      currentAudioPath = outputPath;
      // await _reloadAudio();
    }
  }

  void setEditMode(EditMode mode) {
    editMode = mode;
    isSelecting = mode != EditMode.none;
    if (!isSelecting) {
      selectionStart = 0.0;
      selectionEnd = 0.0;
    }
    notifyListeners();
  }

  //this
  Future<void> applyChanges() async {
    if (!isSelecting) return;

    setBusy(true);

    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}..m4a';

      switch (editMode) {
        case EditMode.trim:
          await trimAudio(outputPath);
          break;
        // case EditMode.insert:
        // await _insertAudio(outputPath);
        // break;
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
    super.dispose();
  }
}

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:stacked/stacked.dart';

class AudioToolViewModel extends BaseViewModel {
  AudioToolViewModel({required this.bookTitle, required this.audioPath});

  final String bookTitle;
  final String? audioPath;

  final AudioPlayer audioPlayer = AudioPlayer();

  bool isPlaying = false,
      isPaused = false,
      isFastForwarding = false,
      isRewinding = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String? currentAudioPath;
  final List<String> undoStack = [];

  @override
  bool isBusy = false;

  Future<void> initializeAudioPlayer(String audioPath) async {
    currentAudioPath = audioPath;
    undoStack.add(audioPath);
    setBusy(true);
    try {
      //get duration using ffmpeg
      await FFmpegKit.execute('-i $audioPath 2>&1 | grep "Duration"').then(
        (session) async {
          final output = await session.getOutput();
          if (output != null) {
            final durationStr = output.split('Duration: ')[1].split(',')[0];
            final parts = durationStr.split(':');
            duration = Duration(
              hours: int.parse(parts[0]),
              minutes: int.parse(parts[1]),
              seconds: double.parse(parts[2]).toInt(),
            );
          }
        },
      );
      //set audio player
      await audioPlayer.setFilePath(audioPath);

      //listen to position changes
      audioPlayer.positionStream.listen((event) {
        position = event;
        notifyListeners();
      });
      //listen to player state changes
      audioPlayer.playerStateStream.listen((state) {
        isPlaying = state.playing;
        isPaused = state.processingState == ProcessingState.completed;
        notifyListeners();
      });
    } catch (e) {
      //handle error
      debugPrint('Error getting duration: $e');
    } finally {
      setBusy(false);
    }
    await audioPlayer.setFilePath(audioPath);
    await audioPlayer.load();
    await audioPlayer.play();
    await audioPlayer.pause();
    setBusy(false);
  }

  void togglePlayPause() {
    if (isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }

  void playPause() {
    // Implement playPause functionality
    if (isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }

  void stop() {
    // Implement stop functionality
    audioPlayer.stop();
  }

  void fastForward() {
    // Implement fastForward functionality
  }

  void rewind() {
    // Implement rewind functionality
  }

  void seekTo(double seconds) {
    // Implement seekTo functionality
    audioPlayer.seek(Duration(seconds: seconds.toInt()));
  }

  //retrive audiopath
}

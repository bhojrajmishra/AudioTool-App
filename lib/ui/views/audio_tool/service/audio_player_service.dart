// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_waveforms/audio_waveforms.dart';

// class AudioPlayerService {
//   final AudioPlayer audioPlayer = AudioPlayer();
//   PlayerController? playerController;
//   bool isPlaying = false;
//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;

//   Future<void> initializeAudioPlayer(String audioPath) async {
//     try {
//       await audioPlayer.setFilePath(audioPath);
//       duration = audioPlayer.duration ?? Duration.zero;

//       audioPlayer.playerStateStream.listen(
//         (state) {
//           isPlaying = state.playing;
//           if (state.processingState == ProcessingState.completed) {
//             isPlaying = false;
//             position = duration;
//           }
//         },
//       );
//     } catch (e) {
//       debugPrint('Error initializing audio player: $e');
//       rethrow;
//     }
//   }

//   Future<void> initializeWaveform(String audioPath) async {
//     try {
//       playerController = PlayerController();
//       await playerController?.preparePlayer(
//         path: audioPath,
//         shouldExtractWaveform: true,
//         noOfSamples: 200,
//         volume: 1.0,
//       );
//     } catch (e) {
//       debugPrint('Error initializing waveform: $e');
//       rethrow;
//     }
//   }

//   Future<void> playPause() async {
//     try {
//       if (audioPlayer.playerState.playing) {
//         await audioPlayer.pause();
//       } else {
//         if (position >= duration ||
//             duration - position < const Duration(milliseconds: 300)) {
//           await audioPlayer.seek(Duration.zero);
//           position = Duration.zero;
//         }
//         await audioPlayer.play();
//       }
//     } catch (e) {
//       debugPrint('Error in playPause: $e');
//       rethrow;
//     }
//   }

//   Future<void> seek(double seconds, Duration totalDuration) async {
//     if (seconds >= 0 && seconds <= totalDuration.inSeconds) {
//       try {
//         await audioPlayer.seek(Duration(seconds: seconds.toInt()));
//         position = Duration(seconds: seconds.toInt());
//       } catch (e) {
//         debugPrint('Error in seek: $e');
//         rethrow;
//       }
//     }
//   }

//   void dispose() {
//     audioPlayer.dispose();
//     playerController?.dispose();
//   }
// }

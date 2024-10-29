import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:stacked/stacked.dart';
import 'package:path/path.dart' as p;

class AudioViewModel extends BaseViewModel {
  double currentPosition = 0;
  double totalDuration = 0;

  /// Instance for audio recorder
  final AudioRecorder audioRecorder = AudioRecorder();

  /// File path for audio file
  final AudioPlayer audioPlayer = AudioPlayer();

  bool isRecording = false, isPlaying = false;

  String? recordingPath;

  /// To play the recording
  void playRecord() async {
    if (audioPlayer.playing) {
      audioPlayer.stop();
      isPlaying = false;
      notifyListeners();
    } else {
      await audioPlayer.setFilePath(recordingPath!);
      audioPlayer.play();
      totalDuration = audioPlayer.duration?.inSeconds.toDouble() ?? 0;
      isPlaying = true;
      audioPlayer.positionStream.listen((position) {
        currentPosition = position.inSeconds.toDouble();
        notifyListeners();
      });
      notifyListeners(); 
    }
  }

  /// To record and stop record
  void playPause() async {
    if (isRecording) {
      final String? filePath = await audioRecorder.stop();
      if (filePath != null) {
        isRecording = false;
        recordingPath = filePath;
        notifyListeners();
      }
    } else {
      isRecording = true;
      if (await audioRecorder.hasPermission()) {
        final Directory appDocumentDir =
            await getApplicationDocumentsDirectory();
        final String filePath = p.join(appDocumentDir.path,
            "recording${DateTime.now().millisecondsSinceEpoch}.caf");
        await audioRecorder.start(
          const RecordConfig(),
          path: filePath,
        );
        recordingPath = null;
        notifyListeners();
      }
    }
  }
}

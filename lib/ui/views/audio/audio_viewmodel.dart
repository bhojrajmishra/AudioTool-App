import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:stacked/stacked.dart';
import 'package:path/path.dart' as p;

class AudioViewModel extends BaseViewModel {
  /// Instance for audio recorder
  final AudioRecorder audioRecorder = AudioRecorder();

  /// File path for audio file
  final AudioPlayer audioPlayer = AudioPlayer();

  bool isRecording = false, isPlaying = false;
  String? recordingPath;
  void playRecord() async {
    if (audioPlayer.playing) {
      audioPlayer.stop();
      isPlaying = false;
      notifyListeners();
    } else {
      await audioPlayer.setFilePath(recordingPath!);
      audioPlayer.play();
      isPlaying = true;
      notifyListeners();
    }
  }

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
        final String filePath = p.join(appDocumentDir.path, "recording.caf");
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

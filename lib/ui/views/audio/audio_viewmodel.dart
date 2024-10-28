import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:stacked/stacked.dart';
import 'package:path/path.dart' as p;

class AudioViewModel extends BaseViewModel {
  /// Instance for audio recorder
  final AudioRecorder audioRecorder = AudioRecorder();

  bool isRecording = false;

  void playPause() async {
    String? recordingPath;
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
        final String filePath = p.join(appDocumentDir.path, "recording.wav");
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

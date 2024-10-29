import 'dart:async';
import 'dart:io';

import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioViewModel extends BaseViewModelWrapper with $HomeView {
  double currentPosition = 0;
  double totalDuration = 0;

  int time = 0;
  bool isRecording = false, isPlaying = false;
  String? audioPath;

  /// Instance for audio recorder
  final AudioRecorder audioRecorder = AudioRecorder();

  /// AudioPlayer to playback audio
  final AudioPlayer audioPlayer = AudioPlayer();

  void tooglePlayPause(button) {
    button = !button;
    notifyListeners();
  }

 
  /// To record and stop record
  void playPause() async {
    /// to stop recording
    if (isRecording) {
      final String? filePath = await audioRecorder.stop();
      if (filePath != null) {
        isRecording = false;
        audioPath = filePath;
        notifyListeners();
      }
    } else {
      /// To start recording
      isRecording = true;
      try {
        if (await audioRecorder.hasPermission()) {
          Directory? dir;

          // Choose directory based on platform
          if (Platform.isIOS) {
            dir = await getApplicationDocumentsDirectory();
          } else {
            dir = Directory('/storage/emulated/0/Download');
            if (!await dir.exists()) {
              dir = await getExternalStorageDirectory();
            }
          }

          // Set the file path for recording
          audioPath = '${dir?.path}/${title1Controller.text}.caf';

          // Start recording to the specified path
          await audioRecorder.start(const RecordConfig(),
              path: audioPath ?? '');
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

 

 

  @override
  void dispose() {
    audioRecorder.dispose();
    audioPlayer.dispose();

    super.dispose();
  }
}

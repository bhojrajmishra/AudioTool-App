import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

class AudioViewModel extends BaseViewModelWrapper with $HomeView {
  double currentPosition = 0;
  double totalDuration = 0;
  Timer? _timer;
  int time = 0;
  bool isRecording = false, isPlaying = false;
  String? audioPath;

  final OnAudioQuery audioQuery = OnAudioQuery();

  /// Instance for audio recorder
  final AudioRecorder audioRecorder = AudioRecorder();

  /// AudioPlayer to playback audio
  final AudioPlayer audioPlayer = AudioPlayer();

  
 /// Retrieve recordings from the directory
  Future<List<FileSystemEntity>> retrieveRecordings() async {
    Directory? dir = await getApplicationDocumentsDirectory();
    return dir.listSync().where((file) => file.path.endsWith('.caf')).toList();
  }

  /// Stop the recording
  Future<void> stop() async {
    final path = await audioRecorder.stop();
    audioPath = path;
    // if (audioPath?.isNotEmpty ?? false) {
    //   log((path ?? "") );
    // }
  }

  /// Statr audio record
  Future<void> start() async {
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
        await audioRecorder.start(const RecordConfig(), path: audioPath ?? '');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> playRecording(String filePath) async {
    try {
      await audioPlayer.setFilePath(filePath);
      audioPlayer.play();
      isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing recording: $e');
    }
  }/// Delete a recording file
  Future<void> deleteRecording(FileSystemEntity file) async {
    await file.delete();
    notifyListeners();
  }
  /// Play the current recording
  void playRecord() {
    if (audioPath != null) {
      playRecording(audioPath!);
    }
  }

  /// To record and stop record
  void playPause() async {
    if (isRecording) {
      final String? filePath = await audioRecorder.stop();
      if (filePath != null) {
        isRecording = false;
        audioPath = filePath;
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
        audioPath = null;
        notifyListeners();
      }
    }
  }

  @override
  void initialise() {
    // requestPermision();
  }
  @override
  void dispose() {
    _timer?.cancel();
    audioRecorder.dispose();
    audioPlayer.dispose();

    super.dispose();
  }
}

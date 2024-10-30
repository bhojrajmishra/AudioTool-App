import 'dart:io';

import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class ChapterListViewModel extends BaseViewModelWrapper with $HomeView {
  double currentPosition = 0;
  double totalDuration = 0;

  int time = 0;
  bool isRecording = false, isPlaying = false;
  String? audioPath;

  void navigationto() {
    navigation.replaceWithAudioView(title: title1Controller.text);
  }

  void popNavigation() {
    navigation.replaceWithHomeView();
  }

  /// AudioPlayer to playback audio
  final AudioPlayer audioPlayer = AudioPlayer();

  ///
  /// Retrieve recordings from the directory
  Future<List<FileSystemEntity>> retrieveRecordings() async {
    Directory? dir = await getApplicationDocumentsDirectory();
    return dir.listSync().where((file) => file.path.endsWith('.caf')).toList();
  }

  /// Delete a recording file
  Future<void> deleteRecording(FileSystemEntity file) async {
    await file.delete();
    notifyListeners();
  }

  /// play back recording
  Future<void> playRecording(String filePath) async {
    if (isPlaying == true) {
      isPlaying = false;
      audioPlayer.pause();
      notifyListeners();
    } else {
      try {
        await audioPlayer.setFilePath(filePath);

        audioPlayer.play();
        isPlaying = true;
        totalDuration = audioPlayer.duration?.inSeconds.toDouble() ?? 0;
        audioPlayer.positionStream.listen((position) {
          currentPosition = position.inSeconds.toDouble();
          notifyListeners();
        });

        notifyListeners();
      } catch (e) {
        debugPrint('Error playing recording: $e');
      }
    }
  }
}

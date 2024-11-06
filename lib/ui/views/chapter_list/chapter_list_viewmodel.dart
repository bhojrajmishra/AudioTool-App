import 'dart:io';
import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ChapterListViewModel extends BaseViewModelWrapper with $HomeView {
  double currentPosition = 0;
  double totalDuration = 0;

  int time = 0;
  bool isRecording = false, isPlaying = false, isPaused = false;
  String? audioPath;
  int? activeIndex;

  /// Instance for audio recorder
  final AudioRecorder audioRecorder = AudioRecorder();

  /// AudioPlayer to playback audio
  final AudioPlayer audioPlayer = AudioPlayer();
  Future<void> pauseResume() async {
    if (isPaused == true) {
      await audioPlayer.play();

      notifyListeners();
    }
    if (isPaused == false) {
      await audioPlayer.pause();

      notifyListeners();
    }
  }

  void toggleButton() {
    isPaused = !isPaused;
    notifyListeners();
  }

  /// play back recording
  Future<void> playBackRecording(String filePath) async {
    if (isPlaying == true) {
      isPlaying = false;

      audioPlayer.stop();
      notifyListeners();
    } else {
      try {
        await audioPlayer.setFilePath(filePath);
        audioPlayer.play();
        isPlaying = true;
        isPaused = false;
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

  // on tap for list
  void onTapRecord(int index) {
    if (activeIndex == index) {
      activeIndex = null;
      isPlaying = false;
      audioPlayer.pause(); // Deselect if already selected
    } else {
      activeIndex = index; // Set the active item index
      isPlaying = false;
      audioPlayer.pause();

      notifyListeners();
    }

    notifyListeners();
  }

  void navigationto() {
    navigation.replaceWithAudioView(title: title1Controller.text);
  }

  void popNavigation() {
    navigation.replaceWithHomeView();
  }

  ///
  /// Retrieve recordings from the directory
  Future<List<FileSystemEntity>> retrieveRecordings() async {
    Directory? dir = await getApplicationDocumentsDirectory();
    notifyListeners();
    List<FileSystemEntity> finalList =
        dir.listSync().where((file) => file.path.endsWith('.caf')).toList();
    finalList.sort((a, b) {
      return a.path.toLowerCase().compareTo(b.path.toLowerCase());
    });
    return finalList;
  }

  /// Delete a recording file
  Future<void> deleteRecording(FileSystemEntity file) async {
    await file.delete();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    title1Controller.dispose();

    notifyListeners();
  }
}

import 'dart:io';
import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:audiobook_record/ui/views/audio/audio_view.form.dart';
import 'package:audiobook_record/ui/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:stacked/stacked.dart';

class ChapterListViewModel extends BaseViewModelWrapper
    with $AudioView
    implements Initialisable {
  ChapterListViewModel({required this.bookTitle});

  double currentPosition = 0;
  double totalDuration = 0;
  String? bookTitle;

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
      _deselectItem();
    } else {
      _selectItem(index);
    }
  }

  void _deselectItem() {
    activeIndex = null;
    isPlaying = false;
    currentPosition = 0;
    audioPlayer.pause();
    notifyListeners();
  }

  void _selectItem(int index) {
    activeIndex = index;
    isPlaying = false;
    audioPlayer.pause();
    currentPosition = 0;
    notifyListeners();
  }

  void navigationto() {
    navigation.replaceWithAudioView(
        title: recordingTitleController.text, bookTitle: bookTitle);
    debugPrint(bookTitle);
  }

  void popNavigation() {
    navigation.clearStackAndShowView(const HomeView());
    bookTitleController.clear();
  }

  ///
  ///
  ///Retrieve recordings from the directory inside the folder named after the book title
  Future<List<FileSystemEntity>> retrieveRecordings() async {
    Directory baseDir;
    if (Platform.isAndroid) {
      baseDir = Directory('/storage/emulated/0/AudioBooks');
    } else if (Platform.isIOS) {
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      return [];
    }

    final bookFolderName = bookTitle!.trim();
    final bookDir = Directory('${baseDir.path}/$bookFolderName');

    if (!await bookDir.exists()) {
      return [];
    }

    List<FileSystemEntity> finalList = bookDir.listSync().where((file) {
      return file.path.endsWith('.m4a');
    }).toList();

    finalList.sort((a, b) {
      return a.path.toLowerCase().compareTo(b.path.toLowerCase());
    });
    notifyListeners();
    return finalList;
  }

  Future<void> deleteRecording(FileSystemEntity file) async {
    try {
      await file.delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting recording: $e');
    }
  }

  @override
  void initialise() {
    retrieveRecordings();
  }
}

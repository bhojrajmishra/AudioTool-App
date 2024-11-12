import 'dart:io';
import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:audiobook_record/ui/views/audio/audio_view.form.dart';
import 'package:audiobook_record/ui/views/audio_tool/audio_tool_view.dart';
import 'package:audiobook_record/ui/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ChapterListViewModel extends BaseViewModelWrapper
    with $AudioView
    implements Initialisable {
  ChapterListViewModel({required this.bookTitle});

  double currentPosition = 0;
  double totalDuration = 0;
  String? bookTitle;
  int time = 0;
  bool isRecording = false,
      isPlaying = false,
      isPaused = false,
      isCurrentPlaying = false;
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

  void togglePlayBackButton(int index) {
    if (activeIndex == index) {
      isCurrentPlaying = !isCurrentPlaying;
      notifyListeners();
    }
  }

// toogle button for play pause
  void toggleButton() {
    isPaused = !isPaused;
    notifyListeners();
  }

  /// play back recording
  Future<void> playBackRecording(String filePath) async {
    if (isPlaying == true) {
      audioPlayer.stop();
      notifyListeners();
    } else {
      try {
        await audioPlayer.setFilePath(filePath);
        audioPlayer.play();

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

  void navigateToAudioToolView(
      {required String bookTitle, required String audioPath}) {
    navigation.navigateToView(
      AudioToolView(
        bookTitle: bookTitle,
        audioPath: audioPath,
      ),
    );
    debugPrint("AudioPath: $audioPath");
  }

  void tooglePlayButton(int index) // select or deselect the item of the list
  {
    if (activeIndex == index) {
      activeIndex = null;
      isPlaying = true;
    } else {
      activeIndex = index;
      isPlaying = false;
      notifyListeners();
    }
  }

  void checkAndNavigate() async {
    final baseDir = await _getBaseDirectory();
    if (baseDir == null) return;

    final bookFolderName = bookTitle.toString().trim();
    final bookDir = Directory('${baseDir.path}/$bookFolderName');
    final audioPath =
        File('${bookDir.path}/${recordingTitleController.text}.m4a');

    if (!await audioPath.exists()) {
      if (recordingTitleController.text.isNotEmpty) {
        navigation.replaceWithAudioView(
          title: recordingTitleController.text,
          bookTitle: bookTitle,
        );
      } else {
        _showEmptyTitleError();
      }
    } else {
      final response = await dialogService.showConfirmationDialog(
        title: 'Audio Already Exists',
        description: 'Do you want to overwrite the existing audio file?',
        confirmationTitle: 'Yes',
        cancelTitle: 'Cancel',
      );
      if (response?.confirmed == true) {
        navigation.replaceWithAudioView(
          title: recordingTitleController.text,
          bookTitle: bookTitle,
        );
      } else {
        recordingTitleController.clear();
      }
    }
  }

  Future<Directory?> _getBaseDirectory() async {
    if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      final androidDir = Directory('/storage/emulated/0/AudioBooks');
      if (await androidDir.exists()) {
        return androidDir;
      } else {
        return await getExternalStorageDirectory();
      }
    }
  }

  void _showEmptyTitleError() {
    showSnackBar.registerCustomSnackbarConfig(
      variant: 'empty title',
      config: SnackbarConfig(
        titleText: const Text("Error"),
        backgroundColor: Colors.white.withOpacity(0.8),
        textColor: Colors.black,
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      ),
    );
    showSnackBar.showCustomSnackBar(
      message: "Recording title cannot be empty",
      variant: 'empty title',
    );
  }

  void popNavigation() {
    navigation.clearStackAndShowView(const HomeView());
    bookTitleController.clear();
    recordingTitleController.clear();
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

    finalList.sort((a, b) // sorts the list
        {
      return a.path.toLowerCase().compareTo(b.path.toLowerCase());
    });
    notifyListeners();
    return finalList;
  }

  Future<void> deleteRecording(FileSystemEntity file) // delete recording
  async {
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

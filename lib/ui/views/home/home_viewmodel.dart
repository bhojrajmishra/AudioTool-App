import 'dart:io';
import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModelWrapper implements Initialisable {
  /// book navigation
  void bookNavigation(String title) {
    navigation.replaceWithChapterListView(booktitle: title);
    debugPrint(title);
  }

  void createBook() {
    if (bookTitleController.text.isNotEmpty) {
      navigation.replaceWithChapterListView(
          booktitle: bookTitleController.text);
      createFolder();
    } else {
      //Snackbar on success
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
        message: "Book title cannot be empty",
        variant: 'empty title',
      );
    }
  }

  Future<List<FileSystemEntity>> retrieveBooks() async {
    Directory? dir;
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = Directory('/storage/emulated/0/AudioBooks');
      if (!await dir.exists()) {
        createFolder();
      }
    }

    List<FileSystemEntity> finalList = dir.listSync().where((file) {
      return !file.path.endsWith('.DS_Store') &&
          !file.path.endsWith('flutter_assets');
    }).toList();

    finalList.sort((a, b) {
      return a.path.toLowerCase().compareTo(b.path.toLowerCase());
    });

    return finalList;
  }

  void createFolder() async {
    Directory? dir;

    dir = Directory('/storage/emulated/0/AudioBooks');
    if (Platform.isAndroid) {
      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory();
      }

      final recordingDir = Directory('/storage/emulated/0/AudioBooks');

      // Create the directory if it doesn't exist
      if (!await recordingDir.exists()) {
        await recordingDir.create(recursive: false);
      }
    }
  }

  Future<void> deleteBooks(FileSystemEntity file) async {
    try {
      file.deleteSync(recursive: true);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting recording: $e');
    }
  }

  @override
  void initialise() {
    retrieveBooks();
  }
}

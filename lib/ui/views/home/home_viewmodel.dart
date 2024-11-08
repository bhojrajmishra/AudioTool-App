import 'dart:io';

import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModelWrapper {
  get snackBar => null;

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

  /// book navigation
  bookNavigation(String title) {
    // navigation.replaceWithAudioView(title: title1Controller.text);
    navigation.replaceWithChapterListView(booktitle: title);
  }

  /// Retrieve recordings from the directory
  Future<List<FileSystemEntity>> retriveBooks() async {
    if (Platform.isIOS) {
      Directory? dir = await getApplicationDocumentsDirectory();
      notifyListeners();

      List<FileSystemEntity> finalList = dir.listSync().where((file) {
        // Exclude files named ".DS_Store"
        return !file.path.endsWith('.DS_Store');
      }).toList();

      // Sort the final list alphabetically by file path
      finalList.sort((a, b) {
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

      return finalList;
    }
    if (Platform.isAndroid) {
      Directory dir = Directory('/storage/emulated/0/Recordings');

      List<FileSystemEntity> finalList = dir.listSync().where((file) {
        // Exclude files named ".DS_Store"
        return !file.path.endsWith('flutter_assets');
      }).toList();

      // Sort the final list alphabetically by file path
      finalList.sort((a, b) {
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

      return finalList;
    }
    return [];
  }

  void createFolder() async {
    Directory? dir;
    dir = await getApplicationDocumentsDirectory();
    // Choose directory based on platform
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory();
      }
    }

    // Create a unique folder for each recording
    final folderName = bookTitleController.text;
    final recordingDir = Directory('${dir!.path}/$folderName');

    // Create the directory if it doesn't exist
    if (!await recordingDir.exists()) {
      await recordingDir.create(recursive: false);
    }
  }
}

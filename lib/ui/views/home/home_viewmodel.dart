import 'dart:io';

import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomeViewModel extends BaseViewModelWrapper with $HomeView {
  void navigationto() {
    // navigation.replaceWithAudioView(title: title1Controller.text);
    navigation.replaceWithChapterListView(
        booktitle: bookTitleController.text.toString());
    createFolder();
    debugPrint(bookTitleController.text.toString());
  }

  /// Retrieve recordings from the directory
  Future<List<FileSystemEntity>> retrieveRecordings() async {
    Directory? dir = await getApplicationDocumentsDirectory();
    notifyListeners();
    List<FileSystemEntity> finalList =
        dir.listSync().where((file) => file.path.contains('book')).toList();
    finalList.sort((a, b) {
      return a.path.toLowerCase().compareTo(b.path.toLowerCase());
    });
    return finalList;
  }

  void createFolder() async {
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

    // Create a unique folder for each recording
    final folderName = bookTitleController.text;
    final recordingDir = Directory('${dir!.path}/$folderName');

    // Create the directory if it doesn't exist
    if (!await recordingDir.exists()) {
      await recordingDir.create(recursive: true);
    }
  }
}

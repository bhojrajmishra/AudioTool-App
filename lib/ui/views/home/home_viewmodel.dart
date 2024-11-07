import 'dart:io';

import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:path_provider/path_provider.dart';

class HomeViewModel extends BaseViewModelWrapper {
  void navigationto() {
    // navigation.replaceWithAudioView(title: title1Controller.text);
    navigation.replaceWithChapterListView(booktitle: bookTitleController.text);
  }

  /// book navigation
  bookNavigation(String title) {
    // navigation.replaceWithAudioView(title: title1Controller.text);
    navigation.replaceWithChapterListView(booktitle: title);
  }

  /// Retrieve recordings from the directory
  Future<List<FileSystemEntity>> retriveBooks() async {
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

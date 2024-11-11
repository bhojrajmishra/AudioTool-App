import 'dart:io';
import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:audiobook_record/ui/views/audio/audio_view.form.dart';
import 'package:audiobook_record/ui/views/chapter_list/chapter_list_view.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioViewModel extends BaseViewModelWrapper with $AudioView {
  AudioViewModel({this.bookTitle});
  String? bookTitle, audioPath;
  double totalDuration = 0, currentPosition = 0;
  bool isRecording = false, isRecordingPaused = false;
  int time = 0;

  /// Instance for audio recorder
  final AudioRecorder audioRecorder = AudioRecorder();

  void backNavigation() //  Back navigation for Icon button appbar
  {
    navigation.clearStackAndShowView(
      ChapterListView(
        booktitle: bookTitle,
      ),
    );
    recordingTitleController.clear();
  }

  void record() // function to record and stop
  async {
    if (isRecording) {
      // Stop recording
      stopRecord();
    } else {
      // Start recording
      startRecord();
    }
  }

  void startRecord() async {
    isRecording = true;
    try {
      if (await audioRecorder.hasPermission()) {
        Directory? baseDir;

        // Choose base directory based on platform
        if (Platform.isIOS) {
          baseDir = await getApplicationDocumentsDirectory();
        } else {
          baseDir = Directory('/storage/emulated/0/AudioBooks');
        }

        // Create a directory for the book using bookTextController
        final bookFolderName = bookTitle.toString().trim();
        final bookDir = Directory('${baseDir.path}/$bookFolderName');

        // Ensure the book directory exists
        if (!await bookDir.exists()) {
          await bookDir.create(recursive: false);
        }

        // Set the file path for the recording inside the book folder
        audioPath = '${bookDir.path}/${recordingTitleController.text}.m4a';

        // Start recording to the specified path
        await audioRecorder.start(
            const RecordConfig(
              numChannels: 2,
              sampleRate: 44100,
              bitRate: 128000,
              noiseSuppress: true,
            ),
            path: audioPath ?? '');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void stopRecord() async {
    final String? filePath = await audioRecorder.stop();
    debugPrint(audioPath);
    if (filePath != null) {
      isRecording = false;
      audioPath = filePath;
      navigation.replaceWithChapterListView(booktitle: bookTitle);
      recordingTitleController.clear();
      notifyListeners();
    }
  }

  void pauseRecording() // Pauses the recording
  async {
    if (isRecordingPaused) {
      await audioRecorder.resume();
    } else {
      await audioRecorder.pause();
    }

    isRecordingPaused = !isRecordingPaused;
    notifyListeners();
  }

  void toogleButton(button) // toogle  button
  {
    button = !button;
    notifyListeners();
  }

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }
}

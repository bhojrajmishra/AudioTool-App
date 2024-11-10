import 'dart:io';
import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:audiobook_record/ui/views/audio/audio_view.form.dart';
import 'package:audiobook_record/ui/views/chapter_list/chapter_list_view.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioViewModel extends BaseViewModelWrapper with $AudioView {
  AudioViewModel({this.bookTitle});
  String? bookTitle;
  double currentPosition = 0;
  double totalDuration = 0;
  int time = 0;
  bool isRecording = false, isPlaying = false, isRecordingPaused = false;
  String? audioPath;

  /// Instance for audio recorder
  final AudioRecorder audioRecorder = AudioRecorder();

  /// AudioPlayer to playback audio
  final AudioPlayer audioPlayer = AudioPlayer();

  void backNavigation() {
    navigation.clearStackAndShowView(
      ChapterListView(
        booktitle: bookTitle,
      ),
    );
    recordingTitleController.clear();
  }

  void tooglePlayPause(button) {
    button = !button;
    notifyListeners();
  }

  void pauseRecording() async {
    if (isRecordingPaused) {
      await audioRecorder.resume();
    } else {
      await audioRecorder.pause();
    }

    isRecordingPaused = !isRecordingPaused;
    notifyListeners();
  }

  /// To record and stop record
  void record() async {
    stopRecord();
  }

  void startRecord() async {
    try {
      if (await audioRecorder.hasPermission()) {
        Directory? baseDir;

        // Choose base directory based on platform
        if (Platform.isIOS) {
          baseDir = await getApplicationDocumentsDirectory();
        } else {
          baseDir = Directory('/storage/emulated/0/AudioBooks');
          if (!await baseDir.exists()) {
            baseDir = await getExternalStorageDirectory();
          }
        }

        // Create a directory for the book using bookTextController
        final bookFolderName = bookTitle.toString().trim();
        final bookDir = Directory('${baseDir?.path}/$bookFolderName');

        // Ensure the book directory exists
        if (!await bookDir.exists()) {
          await bookDir.create(recursive: false);
        }

        // Set the file path for the recording inside the book folder
        audioPath = '${bookDir.path}/${recordingTitleController.text}.m4a';

        // Start recording to the specified path
        await audioRecorder.start(const RecordConfig(), path: audioPath ?? '');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void stopRecord() async {
    if (isRecording) {
      // Stop recording
      final String? filePath = await audioRecorder.stop();
      debugPrint(audioPath);
      if (filePath != null) {
        isRecording = false;
        audioPath = filePath;

        navigation.replaceWithChapterListView(booktitle: bookTitle);
        recordingTitleController.clear();
        notifyListeners();
      }
    } else {
      // Start recording
      isRecording = true;
      startRecord();
    }
  }

  @override
  void dispose() {
    audioRecorder.dispose();
    audioPlayer.dispose();

    super.dispose();
  }
}

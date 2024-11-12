import 'package:stacked/stacked.dart';

class AudioToolViewModel extends BaseViewModel {
  AudioToolViewModel({required this.bookTitle, required this.audioPath});

  final String bookTitle;
  final String? audioPath;

  bool isBusy = false;

  void playPause() {
    // Implement playPause functionality
  }

  void stop() {
    // Implement stop functionality
  }

  void fastForward() {
    // Implement fastForward functionality
  }

  void rewind() {
    // Implement rewind functionality
  }
}

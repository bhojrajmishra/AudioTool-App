import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerController? _playerController;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  AudioPlayer get player => _audioPlayer;
  PlayerController? get playerController => _playerController;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;

  Future<void> initializeAudio(String audioPath) async {
    try {
      await _audioPlayer.setFilePath(audioPath);
      _duration = _audioPlayer.duration ?? Duration.zero;

      _audioPlayer.playerStateStream.listen((state) {
        _isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _position = _duration;
        }
      });
    } catch (e) {
      throw Exception('Failed to initialize audio: $e');
    }
  }

  Future<void> initializeWaveform(String audioPath) async {
    try {
      _playerController = PlayerController();
      await _playerController?.preparePlayer(
        path: audioPath,
        shouldExtractWaveform: true,
        noOfSamples: 200,
        volume: 1.0,
      );

      _playerController?.onCurrentDurationChanged.listen((duration) {
        _position = Duration(milliseconds: duration);
      });
    } catch (e) {
      throw Exception('Failed to initialize waveform: $e');
    }
  }

  Future<void> playPause() async {
    if (_audioPlayer.playerState.playing) {
      await _audioPlayer.pause();
    } else {
      if (_position >= _duration ||
          _duration - _position < const Duration(milliseconds: 300)) {
        await _audioPlayer.seek(Duration.zero);
        _position = Duration.zero;
      }
      await _audioPlayer.play();
    }
  }

  Future<void> seek(double seconds) async {
    if (seconds >= 0 && seconds <= _duration.inSeconds) {
      await _audioPlayer.seek(Duration(seconds: seconds.toInt()));
      _position = Duration(seconds: seconds.toInt());
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _playerController?.dispose();
  }
}

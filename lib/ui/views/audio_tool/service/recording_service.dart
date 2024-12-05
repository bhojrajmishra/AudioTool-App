import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  Duration _currentRecordingDuration = Duration.zero;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<String?> startRecording({
    Duration? maxDuration,
    void Function(Duration)? onProgress,
    void Function()? onMaxDurationReached,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempRecordingPath =
        '${tempDir.path}/temp_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(
            numChannels: 2,
            sampleRate: 44100,
            bitRate: 128000,
            noiseSuppress: true,
          ),
          path: tempRecordingPath,
        );

        _isRecording = true;
        _currentRecordingDuration = Duration.zero;

        // Start timer to track recording duration
        _recordingTimer =
            Timer.periodic(const Duration(milliseconds: 100), (timer) {
          _currentRecordingDuration += const Duration(milliseconds: 100);
          onProgress?.call(_currentRecordingDuration);

          // Check if recording duration exceeds max duration
          if (maxDuration != null && _currentRecordingDuration >= maxDuration) {
            timer.cancel();
            stopRecording().then((_) {
              onMaxDurationReached?.call();
            });
          }
        });

        return tempRecordingPath;
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }

    return null;
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final String? filePath = await _audioRecorder.stop();
      _isRecording = false;

      return filePath;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
  }
}

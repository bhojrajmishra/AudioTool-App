import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingService {
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false;
  String? tempRecordingPath;
  Timer? _recordingTimer;
  Duration _currentRecordingDuration = Duration.zero;

  Future<String?> startRecording(Duration maxAllowedDuration,
      {RecordConfig? config}) async {
    final tempDir = await getTemporaryDirectory();
    tempRecordingPath =
        '${tempDir.path}/temp_insert_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      if (await audioRecorder.hasPermission()) {
        await audioRecorder.start(
          config ??
              const RecordConfig(
                numChannels: 2,
                sampleRate: 44100,
                bitRate: 128000,
                noiseSuppress: true,
              ),
          path: tempRecordingPath!,
        );

        isRecording = true;
        _currentRecordingDuration = Duration.zero;

        _recordingTimer =
            Timer.periodic(const Duration(milliseconds: 100), (timer) async {
          _currentRecordingDuration += const Duration(milliseconds: 100);

          if (_currentRecordingDuration >= maxAllowedDuration) {
            timer.cancel();
            await stopRecording();
          }
        });

        return tempRecordingPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    if (!isRecording) return null;

    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final String? filePath = await audioRecorder.stop();
      isRecording = false;

      return filePath;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      rethrow;
    }
  }

  void dispose() {
    _recordingTimer?.cancel();
    audioRecorder.dispose();
  }
}

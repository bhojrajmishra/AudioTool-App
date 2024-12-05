import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FFmpegService {
  Future<Duration> getAudioDuration(String audioPath) async {
    final session = await FFmpegKit.execute('-i "$audioPath" 2>&1');
    final output = await session.getOutput();

    if (output != null) {
      final durationRegex =
          RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})');
      final match = durationRegex.firstMatch(output);

      if (match != null) {
        return Duration(
          hours: int.parse(match.group(1) ?? '0'),
          minutes: int.parse(match.group(2) ?? '0'),
          seconds: int.parse(match.group(3) ?? '0'),
          milliseconds: (int.parse(match.group(4) ?? '0') * 10),
        );
      }
    }

    throw Exception('Could not determine audio duration');
  }

  Future<String> trimRecordingToFit(
      String recordingPath, Duration targetDuration) async {
    final tempDir = await getTemporaryDirectory();
    final trimmedPath =
        '${tempDir.path}/trimmed_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      final command =
          '-i "$recordingPath" -t ${targetDuration.inMilliseconds / 1000} -c copy "$trimmedPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return trimmedPath;
      } else {
        throw Exception('Failed to trim recording');
      }
    } catch (e) {
      debugPrint('Error trimming recording: $e');
      throw Exception('Failed to trim recording: $e');
    }
  }

  Future<String> insertAudioSegment({
    required String originalPath,
    required String insertPath,
    required Duration selectionStartTime,
    required Duration insertDuration,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempOutputPath =
        '${tempDir.path}/temp_output_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final beforePath = '${tempDir.path}/before.m4a';
    final afterPath = '${tempDir.path}/after.m4a';

    try {
      // Extract before segment
      final beforeCommand =
          '-i "$originalPath" -t ${selectionStartTime.inMilliseconds / 1000} -c copy "$beforePath"';
      final beforeSession = await FFmpegKit.execute(beforeCommand);
      if (!ReturnCode.isSuccess(await beforeSession.getReturnCode())) {
        throw Exception('Failed to extract before segment');
      }

      // Calculate after segment start time
      final afterStartTime = selectionStartTime + insertDuration;
      final afterCommand =
          '-i "$originalPath" -ss ${afterStartTime.inMilliseconds / 1000} -c copy "$afterPath"';
      final afterSession = await FFmpegKit.execute(afterCommand);
      if (!ReturnCode.isSuccess(await afterSession.getReturnCode())) {
        throw Exception('Failed to extract after segment');
      }

      // Create concatenation list
      final listFile = File('${tempDir.path}/list.txt');
      await listFile.writeAsString(
        "file '$beforePath'\nfile '$insertPath'\nfile '$afterPath'",
      );

      // Concatenate using concat demuxer
      final concatCommand = '''
      -f concat -safe 0 -i "${tempDir.path}/list.txt" 
      -c copy 
      "$tempOutputPath"
    '''
          .replaceAll('\n', ' ');

      final concatSession = await FFmpegKit.execute(concatCommand);
      final returnCode = await concatSession.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return tempOutputPath;
      } else {
        throw Exception('Failed to concatenate audio segments');
      }
    } catch (e) {
      debugPrint('Error inserting audio segment: $e');
      throw Exception('Failed to insert audio segment: $e');
    }
  }

  Future<String> trimAudio({
    required String originalPath,
    required Duration selectionStartTime,
    required Duration selectionEndTime,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempOutputPath = path.join(
        tempDir.path, 'temp_trim_${DateTime.now().millisecondsSinceEpoch}.m4a');
    final tempBackupPath = path.join(
        tempDir.path, 'backup_${DateTime.now().millisecondsSinceEpoch}.m4a');

    final beforePath = path.join(
        tempDir.path, 'before_${DateTime.now().millisecondsSinceEpoch}.m4a');
    final afterPath = path.join(
        tempDir.path, 'after_${DateTime.now().millisecondsSinceEpoch}.m4a');

    try {
      // Extract before selection
      if (selectionStartTime > Duration.zero) {
        final beforeCommand =
            '-i "$originalPath" -t ${selectionStartTime.inMicroseconds / 1000000} -c copy "$beforePath"';
        final beforeSession = await FFmpegKit.execute(beforeCommand);
        if (!ReturnCode.isSuccess(await beforeSession.getReturnCode())) {
          throw Exception('Failed to extract before segment');
        }
      }

      // Extract after selection
      if (selectionEndTime < await getAudioDuration(originalPath)) {
        final afterCommand =
            '-i "$originalPath" -ss ${selectionEndTime.inMicroseconds / 1000000} -c copy "$afterPath"';
        final afterSession = await FFmpegKit.execute(afterCommand);
        if (!ReturnCode.isSuccess(await afterSession.getReturnCode())) {
          throw Exception('Failed to extract after segment');
        }
      }

      // Create a list of files to concatenate
      final listFile = File('${tempDir.path}/list.txt');
      String listContent = '';

      if (await File(beforePath).exists()) {
        listContent += "file '$beforePath'\n";
      }
      if (await File(afterPath).exists()) {
        listContent += "file '$afterPath'\n";
      }
      await listFile.writeAsString(listContent);

      // Concatenate segments
      final concatCommand =
          '-f concat -safe 0 -i "${listFile.path}" -c copy "$tempOutputPath"';

      final session = await FFmpegKit.execute(concatCommand);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return tempOutputPath;
      } else {
        final logs = await session.getLogs();
        throw Exception('FFmpeg failed: ${logs.join("\n")}');
      }
    } catch (e) {
      debugPrint('Error trimming audio: $e');
      throw Exception('Failed to trim audio: $e');
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}

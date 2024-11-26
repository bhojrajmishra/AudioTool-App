// import 'dart:async';
// import 'dart:io';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
// import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';

// class FFmpegService {
//   Future<Duration> getAudioDuration(String audioPath) async {
//     try {
//       final session = await FFmpegKit.execute('-i "$audioPath" 2>&1');
//       final output = await session.getOutput();

//       if (output != null) {
//         final durationRegex =
//             RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})');
//         final match = durationRegex.firstMatch(output);

//         if (match != null) {
//           return Duration(
//             hours: int.parse(match.group(1) ?? '0'),
//             minutes: int.parse(match.group(2) ?? '0'),
//             seconds: int.parse(match.group(3) ?? '0'),
//             milliseconds: (int.parse(match.group(4) ?? '0') * 10),
//           );
//         }
//       }
//       throw Exception('Could not determine audio duration');
//     } catch (e) {
//       debugPrint('Error getting audio duration: $e');
//       rethrow;
//     }
//   }

//   Future<void> trimRecordingToFit(
//       String recordingPath, Duration targetDuration) async {
//     final tempDir = await getTemporaryDirectory();
//     final trimmedPath =
//         '${tempDir.path}/trimmed_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

//     try {
//       final command =
//           '-i "$recordingPath" -t ${targetDuration.inMilliseconds / 1000} -c copy "$trimmedPath"';

//       final session = await FFmpegKit.execute(command);
//       final returnCode = await session.getReturnCode();

//       if (ReturnCode.isSuccess(returnCode)) {
//         // Replace original recording with trimmed version
//         await File(trimmedPath).copy(recordingPath);
//         await File(trimmedPath).delete();
//       } else {
//         throw Exception('Failed to trim recording');
//       }
//     } catch (e) {
//       debugPrint('Error trimming recording: $e');
//       rethrow;
//     }
//   }

//   Future<String> extractBeforeSegment(
//       String audioPath, Duration selectionStartTime) async {
//     final tempDir = await getTemporaryDirectory();
//     final beforePath = '${tempDir.path}/preview_before.m4a';

//     final beforeCommand =
//         '-i "$audioPath" -t ${selectionStartTime.inMilliseconds / 1000} -c copy "$beforePath"';

//     final beforeSession = await FFmpegKit.execute(beforeCommand);
//     if (!ReturnCode.isSuccess(await beforeSession.getReturnCode())) {
//       throw Exception('Failed to extract before segment');
//     }

//     return beforePath;
//   }

//   Future<String> extractAfterSegment(
//       String audioPath, Duration afterStartTime) async {
//     final tempDir = await getTemporaryDirectory();
//     final afterPath = '${tempDir.path}/preview_after.m4a';

//     final afterCommand =
//         '-i "$audioPath" -ss ${afterStartTime.inMilliseconds / 1000} -c copy "$afterPath"';

//     final afterSession = await FFmpegKit.execute(afterCommand);
//     if (!ReturnCode.isSuccess(await afterSession.getReturnCode())) {
//       throw Exception('Failed to extract after segment');
//     }

//     return afterPath;
//   }

//   Future<String> concatenateAudioSegments(
//       List<String> segments, String outputPath) async {
//     final tempDir = await getTemporaryDirectory();
//     final listFile = File('${tempDir.path}/segment_list.txt');

//     // Write segments to list file
//     await listFile
//         .writeAsString(segments.map((segment) => "file '$segment'").join('\n'));

//     final concatCommand = '''
//       -f concat -safe 0 -i "${listFile.path}" 
//       -c copy 
//       "$outputPath"
//     '''
//         .replaceAll('\n', ' ');

//     final concatSession = await FFmpegKit.execute(concatCommand);
//     final returnCode = await concatSession.getReturnCode();

//     if (!ReturnCode.isSuccess(returnCode)) {
//       throw Exception('Failed to concatenate audio segments');
//     }

//     // Clean up list file
//     await listFile.delete();

//     return outputPath;
//   }

//   Future<void> trimAudio(String inputPath, String outputPath,
//       Duration startTime, Duration endTime) async {
//     final trimCommand =
//         '-i "$inputPath" -ss ${startTime.inMicroseconds / 1000000} '
//         '-to ${endTime.inMicroseconds / 1000000} -c copy "$outputPath"';

//     final session = await FFmpegKit.execute(trimCommand);
//     final returnCode = await session.getReturnCode();

//     if (!ReturnCode.isSuccess(returnCode)) {
//       throw Exception('Failed to trim audio');
//     }
//   }
// }

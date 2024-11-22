// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class AudioTimeInput extends StatefulWidget {
//   final Duration duration;
//   final Function(Duration, Duration) onManualTimeSet;

//   const AudioTimeInput({
//     super.key,
//     required this.duration,
//     required this.onManualTimeSet,
//   });

//   @override
//   State<AudioTimeInput> createState() => _AudioTimeInputState();
// }

// class _AudioTimeInputState extends State<AudioTimeInput> {
//   final startTimeController = TextEditingController();
//   final endTimeController = TextEditingController();

//   @override
//   void dispose() {
//     startTimeController.dispose();
//     endTimeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(16.r),
//       child: Row(
//         children: [
//           Expanded(
//               child: _buildTimeField(
//                   startTimeController, 'Start Time (HH:mm:ss)')),
//           SizedBox(width: 16.w),
//           Expanded(
//               child: _buildTimeField(endTimeController, 'End Time (HH:mm:ss)')),
//           SizedBox(width: 16.w),
//           _buildSetTimeButton(context),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeField(TextEditingController controller, String label) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//         hintText: '00:00:00',
//       ),
//       keyboardType: TextInputType.text,
//       inputFormatters: [
//         FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
//         LengthLimitingTextInputFormatter(8),
//         _TimeInputFormatter(),
//       ],
//       onChanged: (value) {
//         if (value.length == 2 || value.length == 5) {
//           controller.text = '$value:';
//           controller.selection = TextSelection.fromPosition(
//             TextPosition(offset: controller.text.length),
//           );
//         }
//       },
//     );
//   }

//   Widget _buildSetTimeButton(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () => _validateAndSetTime(context),
//       child: const Text('Set Time'),
//     );
//   }

//   void _validateAndSetTime(BuildContext context) {
//     final startDuration = _parseTimeString(startTimeController.text);
//     final endDuration = _parseTimeString(endTimeController.text);

//     if (startDuration != null && endDuration != null) {
//       if (_isValidTimeRange(startDuration, endDuration)) {
//         widget.onManualTimeSet(startDuration, endDuration);
//       } else {
//         _showError(context, 'Invalid time range. Please check your inputs.');
//       }
//     } else {
//       _showError(context, 'Please enter valid times in HH:mm:ss format.');
//     }
//   }

//   Duration? _parseTimeString(String timeStr) {
//     if (!RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(timeStr)) return null;

//     final parts = timeStr.split(':');
//     try {
//       final hours = int.parse(parts[0]);
//       final minutes = int.parse(parts[1]);
//       final seconds = int.parse(parts[2]);

//       if (hours >= 0 &&
//           hours <= 23 &&
//           minutes >= 0 &&
//           minutes <= 59 &&
//           seconds >= 0 &&
//           seconds <= 59) {
//         return Duration(
//           hours: hours,
//           minutes: minutes,
//           seconds: seconds,
//         );
//       }
//     } catch (e) {
//       return null;
//     }
//     return null;
//   }

//   bool _isValidTimeRange(Duration startTime, Duration endTime) {
//     return endTime > startTime &&
//         startTime.inSeconds >= 0 &&
//         endTime.inSeconds <= widget.duration.inSeconds;
//   }

//   void _showError(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
// }

// class _TimeInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     final newText = newValue.text;

//     if (newText.isEmpty) return newValue;

//     // Remove any colons from the text
//     final strippedText = newText.replaceAll(':', '');

//     if (strippedText.length > 6) return oldValue;

//     // Format the text with colons
//     final buffer = StringBuffer();
//     for (var i = 0; i < strippedText.length; i++) {
//       if (i == 2 || i == 4) buffer.write(':');
//       buffer.write(strippedText[i]);
//     }

//     return TextEditingValue(
//       text: buffer.toString(),
//       selection: TextSelection.collapsed(offset: buffer.length),
//     );
//   }
// }

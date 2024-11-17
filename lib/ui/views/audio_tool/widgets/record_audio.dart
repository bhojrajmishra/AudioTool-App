import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordAudio extends StatelessWidget {
  const RecordAudio({
    super.key,
    required this.isRecording,
    required this.onTap,
  });
  final bool isRecording;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording ? Colors.red : Colors.grey.withOpacity(0.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.stop : Icons.fiber_manual_record,
          color: isRecording ? Colors.white : Colors.red,
          size: 30.sp,
        ),
      ),
    );
  }
}

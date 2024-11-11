import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

BoxDecoration recordingListDecoration(bool? isActive) {
  return BoxDecoration(
      color: isActive! ? Colors.blue.shade100 : Colors.grey.withOpacity(0.4),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: Colors.black.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ]);
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditButton extends StatelessWidget {
  const EditButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.isActive,
      required this.onPressed});
  final IconData icon;
  final String label;
  final bool isActive;
  final void Function() onPressed;

  @override

  /// Builds the widget for the edit button.
  ///
  /// This widget consists of an icon and a label that can be pressed.
  /// The appearance changes based on the [isActive] state.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon for the button
          Icon(
            icon,
            color: isActive ? Colors.red : Colors.green.withOpacity(0.6),
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          // Label text for the button
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.red : Colors.green.withOpacity(0.6),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

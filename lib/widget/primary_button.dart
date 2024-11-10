import 'package:audiobook_record/base/utils/helpers.dart';
import 'package:audiobook_record/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {super.key,
      this.onPressedCallBack,
      required this.title,
      this.color = kcPrimaryColor});
  final String title;
  final Color color;

  /// To set the on pressed function of the button
  final VoidCallback? onPressedCallBack;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          )),
          fixedSize: WidgetStateProperty.all(
              Size(Helpers.getScreenWidth(context) * 0.4.w, 70.h)),
          backgroundColor: WidgetStateProperty.all(color),
        ),
        onPressed: onPressedCallBack,
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 25.sp),
        ));
  }
}

import 'package:audiobook_record/base/utils/helpers.dart';
import 'package:audiobook_record/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, this.onPressedCallBack});

  /// To set the on pressed function of the button
  final VoidCallback? onPressedCallBack;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )),
          fixedSize: WidgetStateProperty.all(
              Size(Helpers.getScreenWidth(context) * 0.3, 100)),
          backgroundColor: WidgetStateProperty.all(kcPrimaryColor),
        ),
        onPressed: onPressedCallBack,
        child: const Text(
          "Save",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ));
  }
}

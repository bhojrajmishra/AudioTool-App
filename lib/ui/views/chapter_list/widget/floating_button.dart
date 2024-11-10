import 'package:audiobook_record/ui/common/app_colors.dart';
import 'package:audiobook_record/ui/common/app_strings.dart';
import 'package:audiobook_record/ui/views/chapter_list/chapter_list_viewmodel.dart';
import 'package:audiobook_record/widget/primary_button.dart';
import 'package:audiobook_record/widget/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton(
      {super.key, required this.title1Controller, required this.viewModel});
  final ChapterListViewModel viewModel;
  final TextEditingController title1Controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      width: 150.w,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all(kcPrimaryColor.withOpacity(0.8)),
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(AppStrings.enterRecordingTitle),

                  /// Button
                  actions: [
                    PrimaryButton(
                      title: AppStrings.save,
                      onPressedCallBack: viewModel.checkAndNavigate,
                    )
                  ],
                  content: PrimaryTextField(
                    controller: title1Controller,
                  ),
                );
              });
        },
        child: Row(
          children: [
            const Icon(
              Icons.mic,
              color: Colors.white,
            ),
            Text(
              "Record",
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

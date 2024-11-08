
import 'package:audiobook_record/ui/common/app_strings.dart';
import 'package:audiobook_record/ui/views/home/home_viewmodel.dart';
import 'package:audiobook_record/widget/primary_button.dart';
import 'package:audiobook_record/widget/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({
    super.key,
    required this.bookTitleController,
    required this.viewModel,
  });

  final TextEditingController bookTitleController;
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding:  EdgeInsets.all(10.0.r),
        child: PrimaryButton(
          title: AppStrings.createBook,
          onPressedCallBack: () {
            /// shows dialog
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(AppStrings.enterBookTitle),

                    /// Button
                    actions: [
                      PrimaryButton(
                          title: AppStrings.create,
                          onPressedCallBack: () {
                            viewModel.createBook();
                          })
                    ],
                    content: PrimaryTextField(
                      controller: bookTitleController,
                      hintText: AppStrings.enterBookTitle,
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}

import 'package:audiobook_record/ui/common/app_strings.dart';
import 'package:audiobook_record/ui/views/chapter_list/chapter_list_viewmodel.dart';
import 'package:audiobook_record/widget/primary_button.dart';
import 'package:audiobook_record/widget/primary_text_field.dart';
import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton(
      {super.key, required this.title1Controller, required this.viewModel});
  final ChapterListViewModel viewModel;
  final TextEditingController title1Controller;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
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
                    onPressedCallBack: viewModel.navigationto,
                  )
                ],
                content: PrimaryTextField(
                  controller: title1Controller,
                ),
              );
            });
      },
      child: const Icon(Icons.add),
    );
  }
}

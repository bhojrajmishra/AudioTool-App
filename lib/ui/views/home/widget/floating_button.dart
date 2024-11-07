import 'package:audiobook_record/ui/views/home/home_viewmodel.dart';
import 'package:audiobook_record/widget/primary_button.dart';
import 'package:audiobook_record/widget/primary_text_field.dart';
import 'package:flutter/material.dart';

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
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: PrimaryButton(
          title: "Create a Book",
          onPressedCallBack: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Enter Book tilte"),

                    /// Button
                    actions: [
                      PrimaryButton(
                          title: "Create",
                          onPressedCallBack: () {
                            viewModel.navigationto();
                            viewModel.createFolder();
                          })
                    ],
                    content: PrimaryTextField(
                      controller: bookTitleController,
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}

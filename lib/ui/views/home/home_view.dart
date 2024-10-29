import 'package:audiobook_record/ui/common/ui_helpers.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:audiobook_record/widget/primary_button.dart';
import 'package:audiobook_record/widget/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import 'home_viewmodel.dart';

@FormView(fields: [
  FormTextField(name: 'title1'),
  FormTextField(name: 'title2'),
])
class HomeView extends StackedView<HomeViewModel> with $HomeView {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Scaffold(
          appBar: AppBar(
            title: const Text("AudioBook"),
          ),
          body: const Padding(
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              /// TextField
              child: Column(
                children: [
                  PrimaryTextField(),
                  verticalSpaceMedium,
                  PrimaryTextField(),
                ],
              ),
            ),
          ),

          /// Button
          bottomNavigationBar: SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: PrimaryButton(
                title: "Next",
                onPressedCallBack: () {
                  viewModel.navigationto();
                },

                /*     onPressedCallBack: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Enter Book tilte"),

                        /// Button
                        actions: [
                          PrimaryButton(
                            title: "Save",
                            onPressedCallBack: viewModel.navigationto,
                          )
                        ],
                        content: PrimaryTextField(
                          controller: title1Controller,
                        ),
                      );
                    });
              } */
              ),
            ),
          ),
        ));
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
}

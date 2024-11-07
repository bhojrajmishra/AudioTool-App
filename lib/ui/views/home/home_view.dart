import 'dart:io';

import 'package:audiobook_record/base/utils/helpers.dart';
import 'package:audiobook_record/ui/common/ui_helpers.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:audiobook_record/widget/primary_button.dart';
import 'package:audiobook_record/widget/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import 'home_viewmodel.dart';

@FormView(fields: [
  FormTextField(
    name: 'title1',
  ),
  FormTextField(name: 'book_title'),
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
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              /// TextField
              child: Column(
                children: [
                  PrimaryTextField(
                    hintText: "Book Title",
                    controller: bookTitleController,
                  ),
                  verticalSpaceMedium,
                  SizedBox(
                    height: Helpers.getScreenHeight(context) * 0.5, // 100,
                    child: FutureBuilder<List<FileSystemEntity>>(
                      future: viewModel.retrieveRecordings(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No recordings found'));
                        }

                        final recordings = snapshot.data!;
                        return ListView.builder(
                          itemCount: recordings.length,
                          itemBuilder: (context, index) {
                            /// to check the item is active or not

                            final file = recordings[index];
                            final fileName = file.path.split('/').last;

                            return GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]),
                                  // duration: const Duration(milliseconds: 200),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        // file  name
                                        title: Text(fileName),

                                        /// Delete Button
                                      ),

                                      /// active row
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
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
                title: "Add",
                onPressedCallBack: () {
                  viewModel.navigationto();
                },
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

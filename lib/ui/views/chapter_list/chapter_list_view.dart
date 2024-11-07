import 'package:audiobook_record/ui/views/chapter_list/widget/floating_button.dart';
import 'package:audiobook_record/ui/views/chapter_list/widget/recording_list.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chapter_list_viewmodel.dart';

class ChapterListView extends StackedView<ChapterListViewModel> with $HomeView {
  const ChapterListView({Key? key, this.booktitle}) : super(key: key);
  final String? booktitle;

  @override
  Widget builder(
    BuildContext context,
    ChapterListViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            booktitle!.isEmpty ? const Text("Book Title") : Text("$booktitle"),
        leading: IconButton(
            onPressed: () {
              viewModel.popNavigation();
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        ///
        /// Recording List
        child: Column(
          children: [
            SizedBox(
              child: RecordingList(
                viewModel: viewModel,
              ),
            ),
          ],
        ),
      ),

      /// Floating action Button
      floatingActionButton: FloatingButton(
        title1Controller: title1Controller,
        viewModel: viewModel,
      ),
    );
  }

  @override
  ChapterListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChapterListViewModel();
}

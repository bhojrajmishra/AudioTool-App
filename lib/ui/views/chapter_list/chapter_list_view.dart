import 'package:audiobook_record/ui/views/audio/audio_view.form.dart';
import 'package:audiobook_record/ui/views/chapter_list/widget/floating_button.dart';
import 'package:audiobook_record/ui/views/chapter_list/widget/recording_list.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chapter_list_viewmodel.dart';

class ChapterListView extends StackedView<ChapterListViewModel>
    with $AudioView {
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
        child: Column(
          children: [
            SizedBox(
              ///
              /// Recording List
              child: RecordingList(
                viewModel: viewModel,
              ),
            ),
          ],
        ),
      ),

      /// Floating action Button
      floatingActionButton: FloatingButton(
        title1Controller: recordingTitleController,
        viewModel: viewModel,
      ),
    );
  }

  @override
  ChapterListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChapterListViewModel(
        bookTitle: booktitle,
      );
}

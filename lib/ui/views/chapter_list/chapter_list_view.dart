import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chapter_list_viewmodel.dart';

class ChapterListView extends StackedView<ChapterListViewModel> {
  const ChapterListView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ChapterListViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      ),
    );
  }

  @override
  ChapterListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChapterListViewModel();
}

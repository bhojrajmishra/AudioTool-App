
import 'package:audiobook_record/ui/common/app_strings.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:audiobook_record/ui/views/home/widget/book_list.dart';
import 'package:audiobook_record/ui/views/home/widget/floating_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import 'home_viewmodel.dart';

@FormView(fields: [
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
          // app bar
          appBar: AppBar(title: const Text(AppStrings.audioBook)),
          body: Padding(
            padding:  EdgeInsets.all(20.0.r),
            child: SingleChildScrollView(
              /// List of books
              child: BooksList(
                viewModel: viewModel,
              ),
            ),
          ),

          /// Buttom Floating Button
          bottomNavigationBar: FloatingButton(
            bookTitleController: bookTitleController,
            viewModel: viewModel,
          ),
        ));
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
}

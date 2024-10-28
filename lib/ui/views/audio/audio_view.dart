import 'package:audiobook_record/ui/common/app_image.dart';
import 'package:audiobook_record/ui/common/ui_helpers.dart';
import 'package:audiobook_record/widget/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'audio_viewmodel.dart';

class AudioView extends StackedView<AudioViewModel> {
  const AudioView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AudioViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Scaffold(
          appBar: AppBar(
            title: const Text('Audio Player'),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz_sharp),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add),
                onPressed: () {},
              )
            ],
          ),
          body: const SingleChildScrollView(
            child: Column(
              children: [
                RoundedImage(imageUrl: AppImage.audioBook),
                verticalSpaceMedium,
                Text("AudioBook Title 1"),
                Text("AudioBook Title 2"),
              ],
            ),
          ),
        ));
  }

  @override
  AudioViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AudioViewModel();
}

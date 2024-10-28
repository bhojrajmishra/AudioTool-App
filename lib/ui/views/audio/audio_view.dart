import 'package:audiobook_record/ui/common/app_image.dart';
import 'package:audiobook_record/ui/common/ui_helpers.dart';
import 'package:audiobook_record/widget/primary_button.dart';
import 'package:audiobook_record/widget/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'audio_viewmodel.dart';

class AudioView extends StackedView<AudioViewModel> {
  const AudioView({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget builder(
    BuildContext context,
    AudioViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Scaffold(
          /// AppBar
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_add),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz_sharp),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const RoundedImage(imageUrl: AppImage.audioBook),
                verticalSpaceMedium,
                const Text("AudioBook Title 1"),
                const Text("AudioBook Title 2"),
                verticalSpaceMedium,
                if (viewModel.recordingPath != null)
                  ElevatedButton(
                      onPressed:viewModel.playRecord,
                      child: viewModel.isPlaying
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow)),
                if (viewModel.recordingPath == null)
                  const Text("No recording found :("),

                verticalSpaceMassive,
                //
                // paly pause buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // previous
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.skip_previous)),
                    // Play or pause
                    IconButton(
                        onPressed: () {
                          viewModel.playPause();
                        },
                        icon: Icon(
                            viewModel.isRecording ? Icons.stop : Icons.mic,
                            color: Colors.red)),

                    /// Next
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.skip_next)),
                  ],
                )
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

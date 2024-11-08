import 'package:audiobook_record/ui/common/app_image.dart';
import 'package:audiobook_record/ui/common/app_strings.dart';
import 'package:audiobook_record/ui/common/ui_helpers.dart';
import 'package:audiobook_record/ui/views/audio/widgets/record_button_row.dart';
import 'package:audiobook_record/widget/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import 'audio_viewmodel.dart';

@FormView(fields: [
  FormTextField(name: 'recordingTitle'),
])
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
                verticalSpaceMedium,
                SizedBox(
                  height: 200,
                  // Animation
                  child: viewModel.isRecording
                      ? (viewModel.isRecordingPaused
                          ? const RoundedImage(imageUrl: AppImage.mic)
                          : const RoundedImage(imageUrl: AppImage.micAnimation))
                      : const RoundedImage(imageUrl: AppImage.mic),
                ),
                // Text
                viewModel.isRecording
                    ? viewModel.isRecordingPaused
                        ? const Text(
                            AppStrings.paused,
                            style: TextStyle(color: Colors.blue, fontSize: 30),
                          )
                        : const Text(
                            AppStrings.recordings,
                            style: TextStyle(color: Colors.red, fontSize: 30),
                          )
                    : const Text(
                        AppStrings.startRecord,
                        style: TextStyle(color: Colors.black, fontSize: 30),
                      ),

                verticalSpaceMedium,
                //
                // paly pause buttons
                verticalSpaceMassive,
                RecordButtonRow(
                  viewModel: viewModel,
                ),
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
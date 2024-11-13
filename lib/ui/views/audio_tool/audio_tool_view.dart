import 'package:audiobook_record/ui/views/audio_tool/widgets/audio_waveform.dart';
import 'package:audiobook_record/ui/views/audio_tool/widgets/edit_button.dart';
import 'package:audiobook_record/ui/views/audio_tool/widgets/play_push_button.dart';
import 'package:audiobook_record/ui/views/audio_tool/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';

import 'audio_tool_viewmodel.dart';

class AudioToolView extends StackedView<AudioToolViewModel> {
  const AudioToolView({
    super.key,
    required this.bookTitle,
    required this.audioPath,
  });
  final String bookTitle;
  final String? audioPath;

  @override
  Widget builder(
    BuildContext context,
    AudioToolViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Audio Waveform Widget
                AudioWaveformWidget(
                  playerController: viewModel.playerController,
                  isLoading: viewModel.isloading,
                ),
                const SizedBox(height: 20),
                // Time and duration
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(viewModel.formatDuration(viewModel.position)),
                      Text(viewModel.formatDuration(viewModel.duration)),
                    ],
                  ),
                ),

                // Progress bar
                ProgressBar(viewModel: viewModel),

                const SizedBox(height: 20),

                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    EditButton(
                      icon: Icons.content_cut,
                      label: 'Trim',
                      isActive: false,
                      onPressed: () {
                        // viewModel.trimAudio(

                        // );
                      },
                    ),
                    PlayPushButton(viewModel: viewModel),
                    EditButton(
                      icon: Icons.playlist_add,
                      label: 'Insert',
                      isActive: false,
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                if (viewModel.isloading)
                  const Center(child: CircularProgressIndicator())
              ],
            )),
      ),
    );
  }

  @override
  AudioToolViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AudioToolViewModel(
        bookTitle: bookTitle,
        audioPath: audioPath,
      );

  // @override
  // void onViewModelReady(AudioToolViewModel viewModel) {
  //   super.onViewModelReady(viewModel);
  //   viewModel.initializeAudioPlayer(audioPath!);
  // }
}

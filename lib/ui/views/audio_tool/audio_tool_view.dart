import 'package:audiobook_record/main.dart';
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
                //waveform visualizer
                Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: viewModel.isBusy
                        ? const Center(child: CircularProgressIndicator())
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Stack(
                              //waveform background
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey.withOpacity(0.05),
                                )
                                //select overlay
                                // if(viewModel.isSelecting)
                                //   Positioned(
                                //     left: viewModel.startPosition,
                                //     right: viewModel.endPosition,
                                //     top: 0,
                                //     bottom: 0,
                                //     child: Container(
                                //       color: Colors.blue.withOpacity(0.3),
                                //     ),
                                //   ),
                              ],
                            ),
                          )),

                const SizedBox(height: 20),
                //time and duration
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            //current time
                            viewModel.formatDuration(viewModel.position)),
                        Text(
                            //total duration
                            viewModel.formatDuration(viewModel.duration)),
                      ],
                    )),
                //progress bar

                ProgressBar(
                  viewModel: viewModel,
                ),

                const SizedBox(height: 20),
                //playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //toggle play/pause
                    // IconButton(
                    //   onPressed: () =>
                    //       viewModel.initializeAudioPlayer(audioPath!),
                    //   icon: viewModel.isPlaying
                    //       ? const Icon(Icons.pause)
                    //       : const Icon(Icons.play_arrow),
                    // ),

                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                        ),
                        iconSize: 30.sp,
                        onPressed: () => viewModel.playPause(),
                      ),
                    ),
                    // IconButton(
                    //   onPressed: viewModel.stop,
                    //   icon: const Icon(Icons.stop),
                    // ),
                    // IconButton(
                    //   onPressed: viewModel.fastForward,
                    //   icon: const Icon(Icons.fast_forward),
                    // ),
                    // IconButton(
                    //   onPressed: viewModel.rewind,
                    //   icon: const Icon(Icons.fast_rewind),
                    // ),
                  ],
                )
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

  @override
  void onViewModelReady(AudioToolViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.initializeAudioPlayer(audioPath!);
  }
}

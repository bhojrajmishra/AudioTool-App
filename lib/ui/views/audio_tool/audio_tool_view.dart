import 'package:flutter/material.dart';
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
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: viewModel.isBusy
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : const Text("Waveform Visualizer"),
                ),
                const SizedBox(height: 20),
                //time and duration
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            //current time
                            "00:00"),
                        Text(
                            //total duration
                            "00:00"),
                      ],
                    )),
                const SizedBox(height: 20),
                //playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //toggle play/pause
                    IconButton(
                      onPressed: () =>
                          viewModel.initializeAudioPlayer(audioPath!),
                      icon: viewModel.isPlaying
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                    ),
                    IconButton(
                      onPressed: viewModel.stop,
                      icon: const Icon(Icons.stop),
                    ),
                    IconButton(
                      onPressed: viewModel.fastForward,
                      icon: const Icon(Icons.fast_forward),
                    ),
                    IconButton(
                      onPressed: viewModel.rewind,
                      icon: const Icon(Icons.fast_rewind),
                    ),
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
}

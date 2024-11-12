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
                        Text("00:00"),
                        Text("00:00"),
                      ],
                    )),
                const SizedBox(height: 20),
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

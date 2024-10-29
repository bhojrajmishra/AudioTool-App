import 'package:audiobook_record/ui/views/audio/audio_viewmodel.dart';
import 'package:flutter/material.dart';

class RecordButtonRow extends StatelessWidget {
  const RecordButtonRow({super.key, required this.viewModel});
  final AudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // previous
        IconButton(
            onPressed: () {
              viewModel.stop();
            },
            icon: const Icon(Icons.skip_previous)),
        // Play or pause
        IconButton(
            onPressed: () {
              viewModel.playPause();
            },
            icon: Icon(viewModel.isRecording ? Icons.stop : Icons.mic,
                color: Colors.red)),

        /// Next
        IconButton(
            onPressed: () {
              viewModel.start();
            },
            icon: const Icon(Icons.skip_next)),
      ],
    );
  }
}

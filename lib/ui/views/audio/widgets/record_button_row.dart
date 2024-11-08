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
        IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous)),
        // Record button
        IconButton(
            onPressed: () {
              viewModel.tooglePlayPause(viewModel.isRecording);
              viewModel.record();
            },
            icon: Icon(
              viewModel.isRecording ? Icons.stop : Icons.mic,
              color: Colors.red,
              size: 50,
            )),

        /// Next
        IconButton(
            onPressed: () {
              viewModel.pauseRecording();
            },
            icon: viewModel.isRecordingPaused
                ? const Icon(
                    Icons.play_circle,
                    color: Colors.red,
                  )
                : const Icon(Icons.pause)),
      ],
    );
  }
}



import 'package:audiobook_record/ui/views/audio/audio_viewmodel.dart';
import 'package:flutter/material.dart';
class SeekBar extends StatelessWidget {
  const SeekBar({
    super.key,
    required this.viewModel
  });
  final AudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: viewModel.currentPosition,
      max: viewModel.totalDuration,
      onChanged: (value) {
        viewModel.audioPlayer.seek(Duration(seconds: value.toInt()));
      },
    );
  }
}

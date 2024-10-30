import 'package:audiobook_record/ui/views/chapter_list/chapter_list_viewmodel.dart';
import 'package:flutter/material.dart';

class SeekBar extends StatelessWidget {
  const SeekBar({super.key, required this.viewModel});
  final ChapterListViewModel viewModel;

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

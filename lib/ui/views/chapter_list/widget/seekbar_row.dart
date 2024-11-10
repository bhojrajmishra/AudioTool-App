import 'package:audiobook_record/ui/views/chapter_list/chapter_list_viewmodel.dart';
import 'package:flutter/material.dart';

class SeekBarRow extends StatelessWidget {
  const SeekBarRow({
    super.key,
    required this.viewModel,
    required this.isActive,
  });
  final bool isActive;

  final ChapterListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isActive
            ? IconButton(
                onPressed: () {
                  viewModel.pauseResume();
                  viewModel.toggleButton();
                },
                icon: viewModel.isPaused
                    ? const Icon(Icons.play_arrow)
                    : const Icon(Icons.pause))
            : SizedBox(
                height: 0,
                child: Text("data"),
              ),

        // seek Bar
        Expanded(
          child: Slider(
            value: viewModel.currentPosition.toDouble(),
            max: viewModel.totalDuration.toDouble(),
            label: viewModel.currentPosition.toStringAsFixed(0),
            onChanged: (value) {
              viewModel.audioPlayer.seek(Duration(seconds: value.toInt()));
            },
            thumbColor: isActive ? Colors.blue : Colors.grey,
            activeColor: isActive ? Colors.blueAccent : Colors.grey,
            inactiveColor: Colors.grey.withOpacity(0.5),
          ),
        ),
        Text("00:${viewModel.currentPosition.toStringAsFixed(0)}"),
      ],
    );
  }
}

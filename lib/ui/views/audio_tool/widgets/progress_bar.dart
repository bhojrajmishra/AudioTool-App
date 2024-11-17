import 'package:audiobook_record/ui/views/audio_tool/audio_tool_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.viewModel});
  final AudioToolViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
        data: SliderThemeData(
          trackHeight: 1.5.h,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
          activeTrackColor: Colors.blue,
          inactiveTrackColor: Colors.grey.withOpacity(0.5),
          thumbColor: Colors.blue,
          overlayColor: Colors.blue.withOpacity(0.3),
        ),
        child: Slider(
          value: viewModel.position.inSeconds
              .toDouble()
              .clamp(0, viewModel.duration.inSeconds.toDouble()),
          max: viewModel.duration.inSeconds.toDouble(),
          onChanged: viewModel.seek,
          secondaryActiveColor: Colors.red,
        ));
  }
}

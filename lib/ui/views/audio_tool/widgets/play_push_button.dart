import 'package:audiobook_record/ui/views/audio_tool/audio_tool_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlayPushButton extends StatelessWidget {
  const PlayPushButton({super.key, required this.viewModel});
  final AudioToolViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.black,
        ),
        iconSize: 30.sp,
        onPressed: viewModel.playPause,
      ),
    );
  }
}

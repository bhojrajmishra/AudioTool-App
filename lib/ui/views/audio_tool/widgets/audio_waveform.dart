import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audiobook_record/ui/views/audio_tool/widgets/audio_input_time.dart';
import 'package:audiobook_record/ui/views/audio_tool/widgets/waveform_display.dart';
import 'package:flutter/material.dart';

class AudioWaveformWidget extends StatelessWidget {
  final PlayerController? playerController;
  final bool isLoading;
  final bool isSelecting;
  final double selectionStart;
  final double selectionWidth;
  final Duration duration;
  final Duration audioDuration;
  final String Function(Duration) formatDuration;
  final Function(double) onSelectionStart;
  final Function(double) onSelectionUpdate;
  final Function() onSelectionEnd;
  final Function(Duration, Duration) onManualTimeSet;

  const AudioWaveformWidget({
    super.key,
    required this.playerController,
    required this.isLoading,
    required this.duration,
    this.isSelecting = false,
    this.selectionStart = 0,
    this.selectionWidth = 0,
    required this.onSelectionStart,
    required this.onSelectionUpdate,
    required this.onSelectionEnd,
    required this.onManualTimeSet,
    required this.formatDuration,
    required this.audioDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isSelecting)
          AudioTimeInput(
            duration: duration,
            onManualTimeSet: onManualTimeSet,
          ),
        WaveformDisplay(
          playerController: playerController,
          isLoading: isLoading,
          isSelecting: isSelecting,
          selectionStart: selectionStart,
          selectionWidth: selectionWidth,
          onSelectionStart: onSelectionStart,
          onSelectionUpdate: onSelectionUpdate,
          onSelectionEnd: onSelectionEnd,
          formatDuration: formatDuration,
          audioDuration: duration,
        ),
      ],
    );
  }
}

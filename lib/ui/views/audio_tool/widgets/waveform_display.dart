import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audiobook_record/ui/views/audio_tool/widgets/audio_selction_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WaveformDisplay extends StatelessWidget {
  final PlayerController? playerController;
  final bool isLoading;
  final bool isSelecting;
  final double selectionStart;
  final double selectionWidth;
  final Function(double) onSelectionStart;
  final Function(double) onSelectionUpdate;
  final Function() onSelectionEnd;
  final Duration audioDuration;
  final String Function(Duration) formatDuration;

  const WaveformDisplay({
    super.key,
    required this.playerController,
    required this.isLoading,
    required this.isSelecting,
    required this.selectionStart,
    required this.selectionWidth,
    required this.onSelectionStart,
    required this.onSelectionUpdate,
    required this.onSelectionEnd,
    required this.audioDuration,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRuler(),
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: LayoutBuilder(
                    builder: _buildWaveformContent,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildWaveformContent(
      BuildContext context, BoxConstraints constraints) {
    return Stack(
      children: [
        _buildBackground(),
        _buildAudioWaveform(),
        if (isSelecting)
          AudioSelectionOverlay(
            selectionStart: selectionStart,
            selectionWidth: selectionWidth,
            constraints: constraints,
          ),
        if (isSelecting) _buildWaveformGesture(constraints),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.withOpacity(0.05),
    );
  }

  Widget _buildAudioWaveform() {
    return AudioFileWaveforms(
      size: Size(double.infinity, 300.h),
      playerController: playerController!,
      enableSeekGesture: !isSelecting, // Disable seek gesture when selecting
      continuousWaveform: true,
      waveformType: WaveformType.long,
      playerWaveStyle: const PlayerWaveStyle(
        fixedWaveColor: Colors.blue,
        liveWaveColor: Colors.red,
        spacing: 4,
        showTop: true,
        showBottom: true,
        seekLineColor: Colors.red,
        showSeekLine: true,
        waveCap: StrokeCap.round,
        scaleFactor: 500,
      ),
    );
  }

  Widget _buildWaveformGesture(BoxConstraints constraints) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (details) {
          // Disable the waveform's seek gesture when selection starts
          // playerController?.pauseAllGestures();
          _handleDragStart(details, constraints);
        },
        onHorizontalDragUpdate: (details) =>
            _handleDragUpdate(details, constraints),
        onHorizontalDragEnd: (details) {
          // Re-enable the waveform's seek gesture when selection ends
          // playerController?.resumeAllGestures();
          onSelectionEnd();
        },
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildRuler() {
    return Row(
      children: List.generate(
        10,
        (index) {
          final position = index / 10;
          return Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                //only show two digi of the seconds not miliseconds
                formatDuration(
                  Duration(
                    milliseconds:
                        (audioDuration.inMilliseconds * position).toInt(),
                  ),
                ).split('.')[0],
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleDragStart(DragStartDetails details, BoxConstraints constraints) {
    final position = details.localPosition.dx / constraints.maxWidth;
    onSelectionStart(position.clamp(0.0, 1.0));
    debugPrint('Start: $position');
  }

  void _handleDragUpdate(
      DragUpdateDetails details, BoxConstraints constraints) {
    final position = details.localPosition.dx / constraints.maxWidth;
    onSelectionUpdate(position.clamp(0.0, 1.0));
    debugPrint('Update: $position');
  }
}

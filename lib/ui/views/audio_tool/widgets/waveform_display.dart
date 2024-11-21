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
          height: 200,
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
        if (isSelecting)
          AudioSelectionOverlay(
            selectionStart: selectionStart,
            selectionWidth: selectionWidth,
            constraints: constraints,
          ),
        //here gesture detector is not properly working as expected which should be first build and then the waveform
        _buildAudioWaveform(),
        _buildWaveformGesture(constraints),
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
      enableSeekGesture: true,
      continuousWaveform: true,
      waveformType: WaveformType.long,
      playerWaveStyle: const PlayerWaveStyle(
        fixedWaveColor: Colors.blue,
        liveWaveColor: Colors.red,
        spacing: 5,
        showTop: true,
        showBottom: true,
        seekLineColor: Colors.red,
        showSeekLine: true,
        waveCap: StrokeCap.round,
        scaleFactor: 1000,
      ),
    );
  }

  Widget _buildWaveformGesture(BoxConstraints constraints) {
    return GestureDetector(
      onHorizontalDragStart: (details) =>
          _handleDragStart(details, constraints),
      onHorizontalDragUpdate: (details) =>
          _handleDragUpdate(details, constraints),
      onHorizontalDragEnd: (_) => onSelectionEnd(),
    );
  }

  //ruler for the waveform count and show in label according to the width of the waveform
  Widget _buildRuler() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Row(
        children: List.generate(
          10,
          (index) {
            final position = index / 10;
            return Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  formatDuration(
                    Duration(
                        seconds: (audioDuration.inSeconds * position).toInt()),
                  ),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            );
          },
        ),
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

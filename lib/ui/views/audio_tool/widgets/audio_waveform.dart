import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioWaveformWidget extends StatelessWidget {
  final PlayerController? playerController;
  final bool isLoading;
  final bool isSelecting;
  final double selectionStart;
  final double selectionWidth;
  final Function(double) onSelectionStart;
  final Function(double) onSelectionUpdate;
  final Function() onSelectionEnd;

  const AudioWaveformWidget({
    super.key,
    required this.playerController,
    required this.isLoading,
    this.isSelecting = false,
    this.selectionStart = 0,
    this.selectionWidth = 0,
    required this.onSelectionStart,
    required this.onSelectionUpdate,
    required this.onSelectionEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.withOpacity(0.05),
                      ),
                      if (playerController != null)
                        GestureDetector(
                          onHorizontalDragStart: (details) {
                            final position =
                                details.localPosition.dx / constraints.maxWidth;
                            onSelectionStart(position);
                            debugPrint('onHorizontalDragStart');
                          },
                          onHorizontalDragUpdate: (details) {
                            final position =
                                details.localPosition.dx / constraints.maxWidth;
                            onSelectionUpdate(position.clamp(0.0, 1.0));
                            debugPrint('onHorizontalDragUpdate');
                          },
                          onHorizontalDragEnd: (_) => onSelectionEnd(),
                          child: AudioFileWaveforms(
                            size: Size(double.infinity, 300.h),
                            playerController: playerController!,
                            waveformType: WaveformType.long,
                            playerWaveStyle: PlayerWaveStyle(
                              fixedWaveColor: Colors.blue.withOpacity(0.5),
                              liveWaveColor: Colors.green,
                              spacing: 5,
                              showTop: true,
                              showBottom: true,
                              seekLineColor: Colors.red,
                              showSeekLine: true,
                              waveCap: StrokeCap.round,
                              scaleFactor: 1000,
                            ),
                          ),
                        ),
                      if (isSelecting)
                        Positioned(
                          left: selectionStart * constraints.maxWidth,
                          width: selectionWidth * constraints.maxWidth,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

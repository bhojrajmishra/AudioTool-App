import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioWaveformWidget extends StatelessWidget {
  final PlayerController? playerController;
  final bool isLoading;
  final bool isSelecting;
  final double selectionStart;
  final double selectionWidth;

  const AudioWaveformWidget({
    super.key,
    required this.playerController,
    required this.isLoading,
    this.isSelecting = false,
    this.selectionStart = 0.0,
    this.selectionWidth = 0.0,
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
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey.withOpacity(0.05),
                  ),
                  //division of the waveform
                  if (playerController != null)
                    GestureDetector(
                      onHorizontalDragStart: (details) {
                        final postition = details.localPosition.dx;
                        onselectionStart(postition);
                        debugPrint('onHorizontalDragStart : $postition');
                      },
                      onHorizontalDragUpdate: (details) {
                        final postition = details.localPosition.dx;
                        onselectionUpdate(postition);
                        debugPrint('onHorizontalDragUpdate : $postition');
                      },
                      onHorizontalDragEnd: (details) {
                        final postition = details.localPosition.dx;
                        onselectionEnd(postition);
                        debugPrint('onHorizontalDragEnd : $postition');
                      },
                      child: AudioFileWaveforms(
                        size: Size(double.infinity, 300.h),
                        playerController: playerController!,
                        waveformType: WaveformType.long,
                        playerWaveStyle: PlayerWaveStyle(
                          fixedWaveColor: Colors.blue.withOpacity(0.5),
                          liveWaveColor: Colors.green.withOpacity(0.5),
                          spacing: 5,
                          showTop: true,
                          showBottom: true,
                          showSeekLine: true,
                          seekLineColor: Colors.red,
                          waveCap: StrokeCap.round,
                          scaleFactor: 1000,
                        ),
                      ),
                    ),
                  //waveform controller gesture detector
                  if (isSelecting)
                    Positioned(
                      left: selectionStart,
                      width: selectionWidth,
                      child: Container(
                        height: double.infinity,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

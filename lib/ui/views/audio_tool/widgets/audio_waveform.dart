import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class AudioWaveformWidget extends StatelessWidget {
  final PlayerController? playerController;
  final bool isLoading;
  final bool isSelecting;
  final double selectionStart;
  final double selectionWidth;
  final Duration duration;
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
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Waveform container with improved styling
      Container(
          height: 180.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.withOpacity(0.05),
                Colors.blue.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Loading audio...',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Waveform background
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.transparent,
                        ),

                        // Audio waveform
                        if (playerController != null)
                          GestureDetector(
                            onHorizontalDragStart: (details) {
                              final position = details.localPosition.dx /
                                  constraints.maxWidth;
                              onSelectionStart(position.clamp(0.0, 1.0));
                            },
                            onHorizontalDragUpdate: (details) {
                              final position = details.localPosition.dx /
                                  constraints.maxWidth;
                              onSelectionUpdate(position.clamp(0.0, 1.0));
                            },
                            onHorizontalDragEnd: (_) => onSelectionEnd(),
                            child: AudioFileWaveforms(
                              size: Size(double.infinity, 180.h),
                              playerController: playerController!,
                              waveformType: WaveformType.fitWidth,
                              playerWaveStyle: PlayerWaveStyle(
                                fixedWaveColor: Colors.blue.withOpacity(0.5),
                                liveWaveColor: Colors.blue,
                                spacing: 4,
                                showTop: true,
                                showBottom: true,
                                seekLineColor: Colors.red,
                                showSeekLine: true,
                                waveCap: StrokeCap.round,
                                scaleFactor: 80,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              backgroundColor: Colors.transparent,
                            ),
                          ),

                        // Selection overlay
                        if (isSelecting)
                          Positioned(
                            left: selectionStart * constraints.maxWidth,
                            width: selectionWidth * constraints.maxWidth,
                            child: Container(
                              height: double.infinity,
                              color: Colors.blue.withOpacity(0.5),
                            ),
                          ),
                      ],
                    );
                  })))
    ]);
  }
}

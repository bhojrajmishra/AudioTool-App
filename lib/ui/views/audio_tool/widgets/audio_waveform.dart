import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioWaveformWidget extends StatelessWidget {
  final PlayerController? playerController;
  final bool isLoading;

  const AudioWaveformWidget({
    super.key,
    required this.playerController,
    required this.isLoading,
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
                    AudioFileWaveforms(
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
                  //waveform controller gesture detector
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';

class AudioSelectionOverlay extends StatelessWidget {
  final double selectionStart;
  final double selectionWidth;
  final BoxConstraints constraints;

  const AudioSelectionOverlay({
    super.key,
    required this.selectionStart,
    required this.selectionWidth,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: selectionStart * constraints.maxWidth,
      width: selectionWidth * constraints.maxWidth,
      top: 0,
      bottom: 0,
      child: Stack(
        children: [
          Container(color: Colors.red.withOpacity(0.3)),
          _buildSelectionHandle(left: true),
          _buildSelectionHandle(left: false),
        ],
      ),
    );
  }

  Widget _buildSelectionHandle({required bool left}) {
    return Positioned(
      left: left ? 0 : null,
      right: left ? null : 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 4,
        color: Colors.red,
      ),
    );
  }
}

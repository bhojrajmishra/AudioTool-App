import 'package:flutter/material.dart';

/// Builds the audio selection overlay widget.
///
/// This widget is used to display a visual representation of the audio selection.
/// It is a [Positioned] widget that is positioned relative to the
/// [AudioWaveformWidget] in the widget tree.
///
/// The [selectionStart] and [selectionWidth] parameters define the portion of
/// the audio that is currently selected. The [constraints] parameter is used to
/// determine the size of the selection overlay.
///
/// The widget is composed of a [Container] with a black background and two
/// [Positioned] widgets that represent the selection handles. The selection
/// handles are used to adjust the selection by dragging them left or right.
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
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: selectionStart * constraints.maxWidth,
      width: selectionWidth * constraints.maxWidth,
      top: 0,
      bottom: 0,
      child: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.3)),
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

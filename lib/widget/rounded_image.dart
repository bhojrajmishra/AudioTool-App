import 'package:flutter/material.dart';

/// create container with ClipRRect
class RoundedImage extends StatelessWidget {
  /// create container with ClipRRect
  ///
  ///
  const RoundedImage(
      {super.key,
      this.borderRadius = 5,
      required this.imageUrl,
      this.height,
      this.width,
      this.color});

  /// sets NetworkImage url for the container
  final String imageUrl;

  /// sets the borderRadius of the ClipRRect
  final double borderRadius;

  /// sets the height and  width of the container
  final double? height, width;

  /// sets the color of the container
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(borderRadius)),
        child: Image(fit: BoxFit.fill, image: AssetImage(imageUrl)),
      ),
    );
  }
}

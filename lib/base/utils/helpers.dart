import 'package:flutter/material.dart';

class Helpers {
  static getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

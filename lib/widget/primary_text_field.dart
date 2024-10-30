import 'package:flutter/material.dart';

class PrimaryTextField extends StatelessWidget {
  const PrimaryTextField({super.key, this.controller, this.hintText});
  final TextEditingController? controller;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ));
  }
}

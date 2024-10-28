import 'package:flutter/material.dart';

class PrimaryTextField extends StatelessWidget {
  const PrimaryTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
      labelText: 'Title 1',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

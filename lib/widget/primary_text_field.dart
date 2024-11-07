import 'package:flutter/material.dart';

class PrimaryTextField extends StatelessWidget {
  const PrimaryTextField({super.key, this.controller, this.hintText,this.validator});
  final TextEditingController? controller;
  final String? hintText;
   /// set the validation of the TextFormField
  final String? Function(String?)? validator;


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
        controller: controller,
        
        decoration: InputDecoration(
        
          labelText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ));
  }
}

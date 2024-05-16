import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String errorMessage;
  final bool isValid;
  final bool showError;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool obscureText;

  const CustomTextField({
    required this.hintText,
    required this.controller,
    required this.onChanged,
    required this.errorMessage,
    required this.isValid,
    this.showError = false,
    this.keyboardType,
    this.readOnly = false,
    this.obscureText = false,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          decoration: InputDecoration(
            hintText: widget.hintText,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            fillColor: Color(0xFFF5F8F9),
            filled: true,
            hintStyle: TextStyle(
              color: Color(0xFF9A9A9A),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        SizedBox(height: (widget.isValid || !widget.showError) ? 0 : 8),
        Visibility(
          visible: !widget.isValid && widget.showError,
          child: Padding(
            padding: EdgeInsets.only(top: widget.isValid ? 0 : 8),
            child: Text(
              widget.errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

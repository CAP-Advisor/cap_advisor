import 'package:flutter/material.dart';

class CustomDropdownButton extends StatefulWidget {
  final List<String> items;
  final String? value;
  final String hintText;
  final Function(String?) onChanged;
  final String errorMessage;
  final bool isValid;
  final bool showError;

  const CustomDropdownButton({
    required this.items,
    required this.value,
    required this.hintText,
    required this.onChanged,
    required this.errorMessage,
    required this.isValid,
    this.showError = false,
  });

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: widget.value,
          items: widget.items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          onChanged: widget.onChanged,
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

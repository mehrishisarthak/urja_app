import 'package:flutter/material.dart';

class UrjaPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const UrjaPasswordField({
    super.key,
    required this.controller,
    this.hintText = "Password",
  });

  @override
  State<UrjaPasswordField> createState() => _UrjaPasswordFieldState();
}

class _UrjaPasswordFieldState extends State<UrjaPasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }
}
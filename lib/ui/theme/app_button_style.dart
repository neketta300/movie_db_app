import 'package:flutter/material.dart';

abstract class AppButtonStyle {
  static final ButtonStyle linkButton = ButtonStyle(
    foregroundColor: WidgetStateProperty.all(const Color(0xFF01B4E4)),
    textStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    ),
  );
}

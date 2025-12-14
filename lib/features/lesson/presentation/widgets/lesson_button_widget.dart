import 'package:flutter/material.dart';

class LessonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool enabled;

  const LessonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              enabled ? const Color(0xFF58CC02) : const Color(0xFFBDBDBD),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

// Использование:
// LessonButton(
//   text: 'ПРОДОЛЖИТЬ',
//   onPressed: () {},
// );

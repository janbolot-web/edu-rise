import 'package:flutter/material.dart';

class LessonImageWidget extends StatelessWidget {
  final String imagePath; // asset or network
  final String? caption;

  const LessonImageWidget({
    super.key,
    required this.imagePath,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 200,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7), // duolingo-like neutral
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 8),
          Text(
            caption!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: Color(0xFF6B6B6B),
            ),
          ),
        ],
      ],
    );
  }
}

// Использование:
// LessonImageWidget(
//   imagePath: 'assets/images/cat.png',
//   caption: 'A cat is sleeping.',
// );

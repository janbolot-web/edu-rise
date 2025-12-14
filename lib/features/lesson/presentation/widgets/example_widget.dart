import 'package:flutter/material.dart';

class ExamplesWidget extends StatelessWidget {
  final List<String> examples;

  const ExamplesWidget({super.key, required this.examples});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Row(
          children: const [
            Icon(Icons.lightbulb_outline, color: Color(0xFF58CC02)),
            SizedBox(width: 8),
            Text(
              'Мисалы:',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                color: Color(0xFF3C3C3C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Карточки примеров
        ...examples.map(
          (text) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8E6), // duolingo light green
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB7E4A8), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: Color(0xFF58CC02),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      height: 1.4,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Использование:
// ExamplesWidget(
//   examples: [
//     'I am a student. — Я студент.',
//     'She likes coffee. — Она любит кофе.',
//   ],
// );

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SmallDescriptionWidget extends StatelessWidget {
  final String text;

  const SmallDescriptionWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: MarkdownBody(
                data: text.toString(),
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                  h1: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  h2: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  em: const TextStyle(fontStyle: FontStyle.italic),
                  strong: const TextStyle(fontWeight: FontWeight.w700),
                  code: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Использование:
// SmallDescriptionWidget(
//   text: 'Это краткое описание правила или темы урока.',
// );

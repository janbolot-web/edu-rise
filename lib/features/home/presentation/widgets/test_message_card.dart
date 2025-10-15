import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:edurise/features/home/presentation/providers/recent_tests_provider.dart';

class TestMessageCard extends StatelessWidget {
  final RecentTest test;
  const TestMessageCard({required this.test, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(colors: [appAccentStart, appAccentEnd]),
            ),
            child: Center(
              child: Text(
                '${test.questions}',
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: appPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${test.date.day}.${test.date.month}.${test.date.year}',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF9AA4B2),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: appAccentEnd),
        ],
      ),
    );
  }
}

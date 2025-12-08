import 'package:flutter/material.dart';

Widget buildOverlayModal(
  int index, {
  int lessonCount = 5,
  int completedLessons = 0,
  int points = 100,
  VoidCallback? onStartTap,
}) {
    final currentLessonNum = (completedLessons < lessonCount) ? (completedLessons + 1) : lessonCount;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0CA9E8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Повторение материала',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text('Урок $currentLessonNum из $lessonCount', style: const TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onStartTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('НАЧАТЬ: +$points ОЧКОВ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0CA9E8)))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

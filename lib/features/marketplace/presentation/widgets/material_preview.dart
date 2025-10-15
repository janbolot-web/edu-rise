import 'package:flutter/material.dart' hide MaterialType;
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../../domain/entities/educational_material.dart';

class MaterialPreview extends StatelessWidget {
  final EducationalMaterial material;
  final VoidCallback onPlay;

  const MaterialPreview({
    super.key,
    required this.material,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appAccentStart.withOpacity(0.8),
            appAccentEnd.withOpacity(0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background image or placeholder
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    appAccentStart.withOpacity(0.3),
                    appAccentEnd.withOpacity(0.5),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  _getMaterialIcon(material.type),
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),

          // Play button overlay
          Center(
            child: GestureDetector(
              onTap: onPlay,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: appAccentEnd,
                ),
              ),
            ),
          ),

          // Material type badge
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getMaterialTypeText(material.type),
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: appPrimary,
                ),
              ),
            ),
          ),

          // Duration badge
          if (material.type == MaterialType.video || material.type == MaterialType.audio)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${material.estimatedTime} мин',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Free badge
          if (material.isFree)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'БЕСПЛАТНО',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getMaterialIcon(MaterialType type) {
    switch (type) {
      case MaterialType.presentation:
        return Icons.slideshow;
      case MaterialType.test:
        return Icons.quiz;
      case MaterialType.notes:
        return Icons.note;
      case MaterialType.worksheet:
        return Icons.assignment;
      case MaterialType.lessonPlan:
        return Icons.schedule;
      case MaterialType.video:
        return Icons.play_circle;
      case MaterialType.audio:
        return Icons.audiotrack;
      case MaterialType.interactive:
        return Icons.touch_app;
    }
  }

  String _getMaterialTypeText(MaterialType type) {
    switch (type) {
      case MaterialType.presentation:
        return 'Презентация';
      case MaterialType.test:
        return 'Тест';
      case MaterialType.notes:
        return 'Конспект';
      case MaterialType.worksheet:
        return 'Рабочий лист';
      case MaterialType.lessonPlan:
        return 'План урока';
      case MaterialType.video:
        return 'Видео';
      case MaterialType.audio:
        return 'Аудио';
      case MaterialType.interactive:
        return 'Интерактив';
    }
  }
}

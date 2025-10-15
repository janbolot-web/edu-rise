import 'package:flutter/material.dart' hide MaterialType;
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../../domain/entities/educational_material.dart';

class MaterialCard extends StatelessWidget {
  final EducationalMaterial material;
  final bool isFeatured;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final bool isFavorite;

  const MaterialCard({
    super.key,
    required this.material,
    this.isFeatured = false,
    required this.onTap,
    required this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: appPrimary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            _buildThumbnail(),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      material.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: appPrimary,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Subject and Grade
                    Row(
                      children: [
                        Flexible(
                          child: _buildInfoChip(
                            material.subject,
                            Icons.book,
                            appAccentStart,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: _buildInfoChip(
                            material.grade,
                            Icons.school,
                            appAccentEnd,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    
                    // Price and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            material.isFree ? 'Бесплатно' : '${material.price.toStringAsFixed(0)} сом',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: material.isFree ? Colors.green : appAccentEnd,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              material.rating.toStringAsFixed(1),
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: appPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: _getGradientForType(material.type),
      ),
      child: Stack(
        children: [
          // Background image or placeholder
          Center(
            child: Icon(
              _getMaterialIcon(material.type),
              size: 48,
              color: appAccentEnd.withOpacity(0.3),
            ),
          ),
          
          // Featured badge
          if (isFeatured)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: appAccentEnd,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Рекомендуется',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          
          // Favorite button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFavoriteTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isFavorite ? Colors.red : appSecondary,
                ),
              ),
            ),
          ),
          
          // Type badge
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getMaterialTypeText(material.type),
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: appPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
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

  LinearGradient _getGradientForType(MaterialType type) {
    switch (type) {
      case MaterialType.presentation:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFEE5A6F),
          ],
        );
      case MaterialType.notes:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4ECDC4),
            Color(0xFF44A08D),
          ],
        );
      case MaterialType.test:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7B733),
            Color(0xFFFC4A1A),
          ],
        );
      case MaterialType.worksheet:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        );
      case MaterialType.lessonPlan:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFA709A),
            Color(0xFFFEE140),
          ],
        );
      case MaterialType.video:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF30CFD0),
            Color(0xFF330867),
          ],
        );
      case MaterialType.audio:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA8E063),
            Color(0xFF56AB2F),
          ],
        );
      case MaterialType.interactive:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFAFBD),
            Color(0xFFFFC3A0),
          ],
        );
    }
  }
}

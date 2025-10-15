import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/test.dart';
import 'package:edurise/core/widgets/safe_network_image.dart';

class TestCard extends StatelessWidget {
  final Test test;
  final VoidCallback onTap;

  const TestCard({
    super.key,
    required this.test,
    required this.onTap,
  });

  List<Color> _getGradientForSubject(String subject) {
    final gradients = {
      'Математика': [const Color(0xFFFF6B6B), const Color(0xFFEE5A6F)],
      'Русский язык': [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
      'Английский язык': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'Физика': [const Color(0xFFF7B733), const Color(0xFFFC4A1A)],
      'Химия': [const Color(0xFF30CFD0), const Color(0xFF330867)],
      'Биология': [const Color(0xFFA8E063), const Color(0xFF56AB2F)],
      'География': [const Color(0xFF4AD3FF), const Color(0xFF00B7FF)],
      'История': [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      'Литература': [const Color(0xFFFFAFBD), const Color(0xFFFFC3A0)],
      'Информатика': [const Color(0xFF02AAB0), const Color(0xFF00CDAC)],
    };
    
    return gradients[subject] ?? [const Color(0xFF6C5CFF), const Color(0xFF4E3BFF)];
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientForSubject(test.subject);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (test.coverImage != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: _CoverImage(src: test.coverImage!),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Icon(
                    Icons.quiz_outlined,
                    size: 48,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildDifficultyChip(),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          test.subject,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${test.gradeLevel} класс',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    test.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    test.description,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(Icons.quiz_outlined, '${test.questionCount} вопросов'),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.timer_outlined, '${test.duration} мин'),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.people_outline, '${test.attempts}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: Text(
                              test.teacherName[0].toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            test.teacherName,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      if (test.averageScore > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${test.averageScore.toStringAsFixed(1)}%',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip() {
    String label;
    
    switch (test.difficulty) {
      case TestDifficulty.easy:
        label = 'Легкий';
        break;
      case TestDifficulty.medium:
        label = 'Средний';
        break;
      case TestDifficulty.hard:
        label = 'Сложный';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  
}

class _CoverImage extends StatelessWidget {
  final String src;
  const _CoverImage({required this.src});

  @override
  Widget build(BuildContext context) {
    return SafeNetworkImage(
      src: src,
      fallbackAsset: 'assets/images/card-1.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 120,
    );
  }
}

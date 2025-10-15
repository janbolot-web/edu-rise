import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:edurise/core/widgets/safe_network_image.dart';
import 'package:edurise/features/courses/domain/entities/course.dart';
import 'package:edurise/features/courses/domain/entities/module.dart';
import 'package:edurise/features/courses/presentation/pages/video_lesson_page.dart';

class PurchasedCourseDetailsPage extends ConsumerWidget {
  final Course course;

  const PurchasedCourseDetailsPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: appBackground,
      body: CustomScrollView(
        slivers: [
          // Гибкий аппбар с изображением курса
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SafeNetworkImage(
                    src: course.imageUrl,
                    // fallback asset available in repo
                    fallbackAsset: 'assets/images/card-2.png',
                    fit: BoxFit.cover,
                  ),
                  // Градиентный оверлей
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                course.title,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: appPrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Добавить в избранное
                },
              ),
            ],
          ),

          // Основной контент
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Прогресс прохождения курса
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: appAccentEnd.withOpacity(0.1),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: appAccentEnd,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ваш прогресс',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: appPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: 0.4, // TODO: Реальный прогресс
                                    backgroundColor: appAccentEnd.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(appAccentEnd),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '40%', // TODO: Реальный процент
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: appAccentEnd,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ProgressStat(
                            icon: Icons.check_circle_outline,
                            title: 'Завершено',
                            value: '4 урока',
                          ),
                          _ProgressStat(
                            icon: Icons.access_time,
                            title: 'Осталось',
                            value: '8 уроков',
                          ),
                          _ProgressStat(
                            icon: Icons.trending_up,
                            title: 'След. урок',
                            value: '25 мин',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Список модулей
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: course.modules.length,
                  itemBuilder: (context, moduleIndex) {
                    final module = course.modules[moduleIndex];
                    return _PurchasedModuleCard(
                      module: module,
                      moduleNumber: moduleIndex + 1,
                      progress: 0.4, // TODO: Реальный прогресс модуля
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // Плавающая кнопка для продолжения обучения
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Перейти к последнему просмотренному уроку
        },
        backgroundColor: appAccentEnd,
        label: Row(
          children: [
            const Icon(Icons.play_arrow_rounded),
            const SizedBox(width: 8),
            Text(
              'Продолжить обучение',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProgressStat({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: appSecondary),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: appSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: appPrimary,
          ),
        ),
      ],
    );
  }
}

class _PurchasedModuleCard extends StatelessWidget {
  final CourseModule module;
  final int moduleNumber;
  final double progress;

  const _PurchasedModuleCard({
    required this.module,
    required this.moduleNumber,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: appAccentEnd.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      moduleNumber.toString(),
                      style: GoogleFonts.montserrat(
                        color: appAccentEnd,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: appPrimary,
                        ),
                      ),
                      Text(
                        '${module.lessons.length} уроков • ${module.duration} минут',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: appSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: appAccentEnd.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(appAccentEnd),
                minHeight: 4,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (module.description.isNotEmpty) ...[
                  Text(
                    module.description,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: appSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ...module.lessons.asMap().entries.map((entry) {
                  final lessonIndex = entry.key;
                  final lesson = entry.value;
                  final isCompleted = false; // TODO: Реальный статус завершения

                  return _PurchasedLessonItem(
                    lesson: lesson,
                    lessonNumber: lessonIndex + 1,
                    isCompleted: isCompleted,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchasedLessonItem extends StatelessWidget {
  final ModuleLesson lesson;
  final int lessonNumber;
  final bool isCompleted;

  const _PurchasedLessonItem({
    required this.lesson,
    required this.lessonNumber,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (lesson.videoUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoLessonPage(
                title: lesson.title,
                youtubeUrl: lesson.videoUrl,
                description: lesson.description,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? appAccentEnd
                    : appAccentEnd.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.play_arrow,
                color: isCompleted ? Colors.white : appAccentEnd,
                size: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                lesson.title,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: appPrimary,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${lesson.duration} мин',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: appSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

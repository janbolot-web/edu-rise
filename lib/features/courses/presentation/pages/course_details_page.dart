import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:edurise/core/widgets/safe_network_image.dart';
import 'package:edurise/features/courses/domain/entities/course.dart';
import 'package:edurise/features/courses/domain/entities/module.dart';
import 'package:edurise/features/courses/presentation/providers/purchased_courses_provider.dart';
import 'package:edurise/features/courses/presentation/pages/purchased_course_details_page.dart';
import 'package:edurise/features/courses/presentation/widgets/purchase_course_dialog.dart';
import 'package:edurise/features/courses/presentation/pages/video_lesson_page.dart';

class CourseDetailsPage extends ConsumerWidget {
  final Course course;

  const CourseDetailsPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPurchasedAsync = ref.watch(courseIsPurchasedProvider(course.id));

    return isPurchasedAsync.when(
      data: (isPurchased) {
        if (isPurchased) {
          return PurchasedCourseDetailsPage(course: course);
        }
        return _UnpurchasedCourseDetailsPage(course: course);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => _UnpurchasedCourseDetailsPage(course: course),
    );
  }
}

class _UnpurchasedCourseDetailsPage extends ConsumerWidget {
  final Course course;

  const _UnpurchasedCourseDetailsPage({
    required this.course,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Существующая реализация для неоплаченного курса
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
                    // course_1.png is not present in repo; use existing card images as fallback
                    fallbackAsset: 'assets/images/card-1.png',
                    fit: BoxFit.cover,
                  ),
                  // Градиентный оверлей для лучшей читаемости
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
          Colors.black.withAlpha(179),
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
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Реализовать шаринг
                },
              ),
            ],
          ),

          // Основной контент
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Информация об авторе
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: appAccentStart,
                          child: Text(
                            course.author[0].toUpperCase(),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.author,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: appPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Преподаватель',
                                style: GoogleFonts.montserrat(
                                  color: appSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Статистика курса
                  Row(
                    children: [
                      Expanded(
                        child: _StatisticItem(
                          icon: Icons.star,
                          value: course.rating.toString(),
                          label: 'Рейтинг',
                          color: const Color(0xFFFFB800),
                        ),
                      ),
                      Expanded(
                        child: _StatisticItem(
                          icon: Icons.play_circle_outline,
                          value: course.lessonsCount.toString(),
                          label: 'Уроков',
                          color: appAccentEnd,
                        ),
                      ),
                      Expanded(
                        child: _StatisticItem(
                          icon: Icons.people_outline,
                          value: '234',
                          label: 'Студентов',
                          color: appPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Описание
                  Text(
                    'О курсе',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: appPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    course.description,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: appSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Что вы изучите
                  Text(
                    'Что вы изучите',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: appPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LearningPoint(text: 'Основы разработки'),
                  _LearningPoint(text: 'Практические навыки'),
                  _LearningPoint(text: 'Работа с реальными проектами'),
                  _LearningPoint(text: 'Современные технологии'),

                  const SizedBox(height: 24),

                  // Программа курса
                  Text(
                    'Программа курса',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: appPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (course.modules.isEmpty)
                    Text(
                      'Программа курса будет доступна после начала обучения',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: appSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: course.modules.length,
                      itemBuilder: (context, moduleIndex) {
                        final module = course.modules[moduleIndex];
                        return _ModuleCard(
                          module: module,
                          moduleNumber: moduleIndex + 1,
                        );
                      },
                    ),

                  const SizedBox(height: 100), // Отступ для кнопки
                ],
              ),
            ),
          ),
        ],
      ),
      // Кнопка записи на курс
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Стоимость',
                  style: GoogleFonts.montserrat(
                    color: appSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${course.price.toInt()} ₽',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: appPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => PurchaseCourseDialog(
                      courseId: course.id,
                      courseName: course.title,
                      price: course.price,
                    ),
                  );
                  
                  if (result == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Поздравляем с покупкой курса!'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appAccentEnd,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Записаться на курс',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatisticItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: appSecondary,
          ),
        ),
      ],
    );
  }
}

class _LearningPoint extends StatelessWidget {
  final String text;

  const _LearningPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: appAccentEnd.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.check,
              color: appAccentEnd,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: appSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final CourseModule module;
  final int moduleNumber;

  const _ModuleCard({
    required this.module,
    required this.moduleNumber,
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
        title: Row(
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
                  return _LessonItem(
                    lesson: lesson,
                    lessonNumber: lessonIndex + 1,
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

class _LessonItem extends StatelessWidget {
  final ModuleLesson lesson;
  final int lessonNumber;

  const _LessonItem({
    required this.lesson,
    required this.lessonNumber,
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Text(
              '$lessonNumber.',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: appSecondary,
              ),
            ),
            const SizedBox(width: 8),
            if (lesson.videoUrl.isNotEmpty) ...[
              Icon(
                Icons.play_circle_outline,
                color: appAccentEnd,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                lesson.title,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: appPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (lesson.isPreview)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: appAccentEnd.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Превью',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: appAccentEnd,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
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

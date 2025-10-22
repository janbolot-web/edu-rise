import 'package:edurise/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/features/home/presentation/providers/recent_tests_provider.dart';
import 'package:edurise/features/home/presentation/widgets/test_message_card.dart';
// import 'package:edurise/features/courses/presentation/providers/courses_provider.dart';
import 'package:edurise/features/home/presentation/providers/courses_with_gradient_provider.dart';
import 'package:edurise/features/courses/domain/entities/course.dart';
import 'package:edurise/features/courses/presentation/pages/course_details_page.dart';
import 'package:edurise/core/widgets/safe_network_image.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined, color: appPrimary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Привет, Анкур!',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: appPrimary,
                        ),
                      ),
                    ),
                    // avatar
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.asset(
                            'assets/images/author.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.person, color: appPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Найдите свой любимый\nобразовательный курс',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: appPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFFBEC8D6)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Поиск курсов',
                                style: GoogleFonts.montserrat(
                                  color: const Color(0xFFBEC8D6),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [appAccentStart, appAccentEnd],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: appAccentEnd..withAlpha(102),
                            blurRadius: 8,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Мои курсы',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: appPrimary,
                      ),
                    ),
                    Text(
                      'Все курсы',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: appAccentEnd,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // make horizontal list full-bleed without negative margin
              Consumer(builder: (context, ref, _) {
                final coursesAsync = ref.watch(coursesWithGradientProvider);

                return coursesAsync.when(
                  data: (coursesWithGradient) {
                    if (coursesWithGradient.isEmpty) {
                      return SizedBox(
                        height: 180,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Нет курсов',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9AA4B2)),
                            ),
                          ),
                        ),
                      );
                    }

                    // take up to 4 latest courses — backend may already order; if not, assume list order is by added time and take last elements
                    final take = coursesWithGradient.length < 4 ? coursesWithGradient.length : 4;
                    final latest = coursesWithGradient.sublist(coursesWithGradient.length - take, coursesWithGradient.length).reversed.toList();

                    final screenWidth = MediaQuery.of(context).size.width;
                    return SizedBox(
                      height: 330,
                      width: screenWidth,
                      child: ListView.separated(
                  
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: latest.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final item = latest[index];
                          final course = item.course;
                          return SizedBox(
                            width: 260,
                            child: HomeCourseCard(
                              course: course,
                              gradientHex: item.gradientColors,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CourseDetailsPage(course: course),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                  error: (e, st) => SizedBox(
                    height: 180,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Ошибка при загрузке курсов', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Курсы от менторов',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: appPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  return Transform.translate(
                    offset: const Offset(0, 0),
                    child: SizedBox(
                      width: screenWidth,
                      height: 78,
                      child: ListView.separated(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) =>
                            MentorPill(index: index),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // --- Tests section (minimalist) ---------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Тесты',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: appPrimary,
                      ),
                    ),
                    // optional action, keep minimal
                    Text(
                      'Все',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: appAccentEnd,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final testsAsync = ref.watch(recentTestsProvider);

                  return testsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
                    ),
                    error: (e, st) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Ошибка при загрузке тестов', style: GoogleFonts.montserrat(color: const Color(0xFF9AA4B2))),
                    ),
                    data: (tests) {
                      if (tests.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Нет недавних тестов',
                            style: GoogleFonts.montserrat(
                                color: const Color(0xFF9AA4B2)),
                          ),
                        );
                      }

                      // show up to 3 recent tests
                      final shown = tests.length > 3 ? tests.sublist(0, 3) : tests;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            for (var t in shown) ...[
                              TestMessageCard(test: t),
                              const SizedBox(height: 10),
                            ]
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final int index;
  const CourseCard({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [const Color(0xffFFAC71), const Color(0xffFF8450)],
      [const Color(0xff02AAB0), const Color(0xff00CDAC)],
      [const Color(0xFF6C5CFF), const Color(0xFF4E3BFF)],
      [const Color(0xFF4AD3FF), const Color(0xFF00B7FF)],
    ];
    final grad = gradients[index % gradients.length];

    return SizedBox(
      width: 260,
      child: Stack(
        children: [
          Container(
            width: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                colors: grad,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: grad.last.withAlpha(51),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/card-${(index % 2) + 1}.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const FlutterLogo(size: 88),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Поиск соучредителя\nна раннем этапе',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: AssetImage('assets/images/author.png'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Анкур Варику',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 0,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                'assets/images/icon-play.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MentorPill extends StatelessWidget {
  final int index;
  const MentorPill({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final bgGradients = [
      [const Color(0xFF4C9BFF), const Color(0xFF1E7BFF)],
      [const Color(0xFF666666), const Color(0xFF222222)],
      [const Color(0xFF6C5CFF), const Color(0xFF5043FF)],
      [const Color(0xFF00C7B7), const Color(0xFF00A89A)],
    ];
    final bg = bgGradients[index % bgGradients.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bg,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/author.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Анкур Варику',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Основатель Nearby | Ментор',
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final List<String>? gradientHex;

  const HomeCourseCard({super.key, required this.course, this.onTap, this.gradientHex});

  @override
  Widget build(BuildContext context) {
    List<Color> grad;
    if (gradientHex != null && gradientHex!.isNotEmpty) {
      grad = gradientHex!.map((h) {
        var hex = h.replaceAll('#', '').trim();
        if (hex.length == 6) hex = 'FF$hex';
        final value = int.tryParse(hex, radix: 16) ?? 0xFFFFFFFF;
        return Color(value);
      }).toList();
    } else {
      final defaults = [
        [const Color(0xffFFAC71), const Color(0xffFF8450)],
        [const Color(0xff02AAB0), const Color(0xff00CDAC)],
        [const Color(0xFF6C5CFF), const Color(0xFF4E3BFF)],
        [const Color(0xFF4AD3FF), const Color(0xFF00B7FF)],
      ];
      grad = defaults[course.id.hashCode % defaults.length];
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomLeft),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: grad.last.withAlpha(40), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: SafeNetworkImage(
                        src: course.imageUrl,
                        fallbackAsset: 'assets/images/card-1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.title,
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(radius: 14, backgroundImage: AssetImage('assets/images/author.png')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          course.author,
                          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
            top: 8,
            right: 0,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                'assets/images/icon-play.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

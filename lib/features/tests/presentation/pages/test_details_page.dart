import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edurise/core/widgets/safe_network_image.dart';
import '../../domain/models/test.dart';
import '../../domain/models/test_attempt.dart';
import '../providers/test_providers.dart';
import 'test_taking_page.dart';

class TestDetailsPage extends ConsumerWidget {
  final String testId;

  const TestDetailsPage({
    super.key,
    required this.testId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testAsync = ref.watch(testProvider(testId));
    final currentUser = FirebaseAuth.instance.currentUser;
    final attemptsAsync = currentUser != null
        ? ref.watch(testAttemptsProvider(testId))
        : const AsyncValue<List<TestAttempt>>.data([]);

    return testAsync.when(
      data: (test) {
        if (test == null) {
          return _buildErrorScaffold(context, 'Тест не найден');
        }
        return _buildContent(context, ref, test, attemptsAsync);
      },
      loading: () => _buildLoadingScaffold(context),
      error: (error, stack) => _buildErrorScaffold(context, error.toString()),
    );
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: appAccentEnd),
      ),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: appPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Test test,
      AsyncValue<List<TestAttempt>> attemptsAsync) {
    return Scaffold(
      backgroundColor: appBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: test.coverImage != null
                  ? _FlexibleCover(src: test.coverImage!, fallback: _buildDefaultCover(test))
                  : _buildDefaultCover(test),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Share test
                },
                icon: const Icon(Icons.share, color: Colors.white),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: appPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTeacherInfo(test),
                  const SizedBox(height: 20),
                  _buildTestInfo(test),
                  const SizedBox(height: 24),
                  _buildDescription(test),
                  const SizedBox(height: 24),
                  _buildStartButton(context, test),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: appBackground,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(test),
                  const SizedBox(height: 24),
                  attemptsAsync.when(
                    data: (attempts) {
                      final userAttempts = attempts
                          .where((a) =>
                              a.userId ==
                              FirebaseAuth.instance.currentUser?.uid)
                          .toList();
                      if (userAttempts.isNotEmpty) {
                        return _buildPreviousAttempts(userAttempts);
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCover(Test test) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appAccentStart, appAccentEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.quiz,
          size: 100,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildTeacherInfo(Test test) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: appAccentEnd,
          radius: 20,
          child: Text(
            test.teacherName[0].toUpperCase(),
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              test.teacherName,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: appPrimary,
              ),
            ),
            Text(
              'Преподаватель',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: appSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestInfo(Test test) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.quiz,
                  '${test.questionCount}',
                  'вопросов',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.timer,
                  '${test.duration}',
                  'минут',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.signal_cellular_alt,
                  _getDifficultyText(test.difficulty),
                  'сложность',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.book,
                  test.subject,
                  '${test.gradeLevel} класс',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: appAccentEnd, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: appPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: appSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(Test test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: appPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          test.description,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: appPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context, Test test) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [appAccentStart, appAccentEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TestTakingPage(testId: test.id),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Начать тест',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(Test test) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '${test.averageScore.toStringAsFixed(1)}%',
                'Средний балл',
              ),
              Container(
                width: 1,
                height: 40,
                color: appBackground,
              ),
              _buildStatItem(
                '${test.attempts}',
                'Попыток',
              ),
              Container(
                width: 1,
                height: 40,
                color: appBackground,
              ),
              _buildStatItem(
                '${test.totalPoints}',
                'Баллов',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: appAccentEnd,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: appSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviousAttempts(List<TestAttempt> attempts) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ваши попытки',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...attempts.take(5).map((attempt) => _buildAttemptItem(attempt)),
        ],
      ),
    );
  }

  Widget _buildAttemptItem(TestAttempt attempt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${attempt.percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: attempt.isPassed ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '${attempt.score}/${attempt.totalPoints} баллов',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: appSecondary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                attempt.isPassed ? 'Пройден' : 'Не пройден',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: attempt.isPassed ? Colors.green : Colors.red,
                ),
              ),
              if (attempt.completedAt != null)
                Text(
                  _formatDate(attempt.completedAt!),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: appSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(TestDifficulty difficulty) {
    switch (difficulty) {
      case TestDifficulty.easy:
        return 'Легкий';
      case TestDifficulty.medium:
        return 'Средний';
      case TestDifficulty.hard:
        return 'Сложный';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

class _FlexibleCover extends StatelessWidget {
  final String src;
  final Widget fallback;
  const _FlexibleCover({required this.src, required this.fallback});

  @override
  Widget build(BuildContext context) {
    return SafeNetworkImage(
      src: src,
      fallbackAsset: 'assets/images/card-1.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

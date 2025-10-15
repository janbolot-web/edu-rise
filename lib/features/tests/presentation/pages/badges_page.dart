import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/test_providers.dart';

class BadgesPage extends ConsumerWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        body: Center(child: Text('Необходимо войти в систему')),
      );
    }

    final statsAsync = ref.watch(userStatsProvider(userId));

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Достижения',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: appPrimary,
          ),
        ),
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats == null) return const Center(child: Text('Загрузка...'));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCard(stats),
                const SizedBox(height: 24),
                Text(
                  'Бейджи',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: appPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBadgesGrid(stats.earnedBadges),
                const SizedBox(height: 24),
                Text(
                  'Статистика',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: appPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailedStats(stats),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  Widget _buildStatsCard(stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appAccentStart, appAccentEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appAccentEnd.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.emoji_events,
                value: '${stats.totalPoints}',
                label: 'Очки',
              ),
              _buildStatItem(
                icon: Icons.local_fire_department,
                value: '${stats.currentStreak} дней',
                label: 'Streak',
              ),
              _buildStatItem(
                icon: Icons.military_tech,
                value: '${stats.earnedBadges.length}',
                label: 'Бейджей',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesGrid(List<String> earnedBadges) {
    final allBadges = [
      BadgeInfo(
        id: 'first_test',
        name: 'Первый шаг',
        description: 'Пройден первый тест',
        icon: Icons.rocket_launch,
        color: Colors.blue,
      ),
      BadgeInfo(
        id: 'test_taker',
        name: 'Знаток тестов',
        description: 'Пройдено 10 тестов',
        icon: Icons.school,
        color: Colors.green,
      ),
      BadgeInfo(
        id: 'test_master',
        name: 'Мастер тестов',
        description: 'Пройдено 50 тестов',
        icon: Icons.emoji_events,
        color: Colors.amber,
      ),
      BadgeInfo(
        id: 'perfectionist',
        name: 'Перфекционист',
        description: 'Получено 100% в тесте',
        icon: Icons.star,
        color: Colors.purple,
      ),
      BadgeInfo(
        id: 'streak_7',
        name: 'Неделя подряд',
        description: '7 дней streak',
        icon: Icons.local_fire_department,
        color: Colors.orange,
      ),
      BadgeInfo(
        id: 'streak_30',
        name: 'Месяц подряд',
        description: '30 дней streak',
        icon: Icons.whatshot,
        color: Colors.red,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: allBadges.length,
      itemBuilder: (context, index) {
        final badge = allBadges[index];
        final isEarned = earnedBadges.contains(badge.id);
        
        return _buildBadgeCard(badge, isEarned);
      },
    );
  }

  Widget _buildBadgeCard(BadgeInfo badge, bool isEarned) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned ? badge.color : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          if (isEarned)
            BoxShadow(
              color: badge.color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEarned ? badge.color.withOpacity(0.1) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge.icon,
              size: 40,
              color: isEarned ? badge.color : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.name,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isEarned ? appPrimary : appSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: appSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(stats) {
    return Column(
      children: [
        _buildStatRow('Всего тестов', '${stats.totalTests}'),
        _buildStatRow('Пройдено', '${stats.testsCompleted}'),
        _buildStatRow('Успешно сдано', '${stats.testsPassed}'),
        _buildStatRow('Процент успеха', '${stats.passRate.toStringAsFixed(1)}%'),
        _buildStatRow('Средний балл', '${stats.averageScore.toStringAsFixed(1)}%'),
        _buildStatRow('Лучший streak', '${stats.longestStreak} дней'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: appSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: appPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class BadgeInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  BadgeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

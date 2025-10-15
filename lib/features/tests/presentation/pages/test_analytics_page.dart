import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/test.dart';
import '../../domain/models/test_attempt.dart';
import 'create_test_page.dart';

final testAnalyticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, testId) async {
  final repo = ref.read(testRepositoryProvider);
  final test = await repo.getTest(testId);
  final attempts = await repo.getTestAttempts(testId);
  
  return {
    'test': test,
    'attempts': attempts,
  };
});

class TestAnalyticsPage extends ConsumerWidget {
  final String testId;

  const TestAnalyticsPage({super.key, required this.testId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(testAnalyticsProvider(testId));

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Аналитика теста',
          style: GoogleFonts.montserrat(
            color: appPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: appPrimary),
            onPressed: () => _exportToCSV(context),
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (data) {
          final test = data['test'] as Test?;
          final attempts = data['attempts'] as List<TestAttempt>;
          
          if (test == null) {
            return const Center(child: Text('Тест не найден'));
          }

          return _buildContent(context, test, attempts);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: appAccentEnd)),
        error: (error, _) => Center(
          child: Text('Ошибка: $error', style: GoogleFonts.montserrat()),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Test test, List<TestAttempt> attempts) {
    final stats = _calculateStats(test, attempts);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOverallStats(stats),
        const SizedBox(height: 16),
        _buildScoreDistribution(attempts),
        const SizedBox(height: 16),
        _buildQuestionPerformance(test, attempts),
        const SizedBox(height: 16),
        _buildStudentList(attempts),
        const SizedBox(height: 16),
        _buildWeakTopics(test, attempts),
      ],
    );
  }

  Widget _buildOverallStats(Map<String, dynamic> stats) {
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
            'Общая статистика',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('Всего попыток', '${stats['totalAttempts']}', Icons.people)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Средний балл', '${stats['averageScore']}%', Icons.bar_chart)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Завершили', '${stats['completionRate']}%', Icons.check_circle)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Успешно', '${stats['passRate']}%', Icons.star)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: appAccentEnd, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: appSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDistribution(List<TestAttempt> attempts) {
    if (attempts.isEmpty) return const SizedBox.shrink();

    final ranges = {
      '0-20%': 0,
      '21-40%': 0,
      '41-60%': 0,
      '61-80%': 0,
      '81-100%': 0,
    };

    for (final attempt in attempts) {
      if (attempt.percentage <= 20) {
        ranges['0-20%'] = ranges['0-20%']! + 1;
      } else if (attempt.percentage <= 40) {
        ranges['21-40%'] = ranges['21-40%']! + 1;
      } else if (attempt.percentage <= 60) {
        ranges['41-60%'] = ranges['41-60%']! + 1;
      } else if (attempt.percentage <= 80) {
        ranges['61-80%'] = ranges['61-80%']! + 1;
      } else {
        ranges['81-100%'] = ranges['81-100%']! + 1;
      }
    }

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
            'Распределение баллов',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: ranges.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
                barGroups: ranges.entries.toList().asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: appAccentEnd,
                        width: 32,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ranges.keys.toList();
                        if (value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: GoogleFonts.montserrat(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.montserrat(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPerformance(Test test, List<TestAttempt> attempts) {
    if (attempts.isEmpty) return const SizedBox.shrink();

    final questionStats = <String, Map<String, int>>{};
    
    for (final question in test.questions) {
      questionStats[question.id] = {'correct': 0, 'total': 0};
    }

    for (final attempt in attempts) {
      for (final question in test.questions) {
        if (attempt.answers.containsKey(question.id)) {
          questionStats[question.id]!['total'] = questionStats[question.id]!['total']! + 1;
          if (!attempt.incorrectQuestions.contains(question.id)) {
            questionStats[question.id]!['correct'] = questionStats[question.id]!['correct']! + 1;
          }
        }
      }
    }

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
            'Производительность по вопросам',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...test.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final stats = questionStats[question.id]!;
            final total = stats['total']!;
            final correct = stats['correct']!;
            final percentage = total > 0 ? (correct / total * 100).round() : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: appAccentEnd.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              color: appAccentEnd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question.text,
                          style: GoogleFonts.montserrat(color: appPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: percentage >= 70 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: appBackground,
                    color: percentage >= 70 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$correct из $total правильно',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: appSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<TestAttempt> attempts) {
    final sortedAttempts = List<TestAttempt>.from(attempts)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

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
            'Результаты учеников',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (sortedAttempts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Пока нет попыток',
                  style: GoogleFonts.montserrat(color: appSecondary),
                ),
              ),
            )
          else
            ...sortedAttempts.take(10).map((attempt) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: attempt.isPassed ? Colors.green : Colors.red,
                  child: Text(
                    attempt.userName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  attempt.userName,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Время: ${attempt.timeSpent ~/ 60} мин ${attempt.timeSpent % 60} сек',
                  style: GoogleFonts.montserrat(fontSize: 12, color: appSecondary),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${attempt.percentage.toStringAsFixed(0)}%',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: attempt.isPassed ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      '${attempt.score}/${attempt.totalPoints}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: appSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildWeakTopics(Test test, List<TestAttempt> attempts) {
    if (attempts.isEmpty) return const SizedBox.shrink();

    final questionErrors = <String, int>{};
    for (final attempt in attempts) {
      for (final qId in attempt.incorrectQuestions) {
        questionErrors[qId] = (questionErrors[qId] ?? 0) + 1;
      }
    }

    final sortedErrors = questionErrors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topErrors = sortedErrors.take(5).toList();

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
            'Слабые места',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (topErrors.isEmpty)
            Text(
              'Отлично! Все вопросы выполнены без ошибок',
              style: GoogleFonts.montserrat(color: Colors.green),
            )
          else
            ...topErrors.map((entry) {
              final question = test.questions.firstWhere((q) => q.id == entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.error_outline, color: Colors.red, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.text,
                            style: GoogleFonts.montserrat(color: appPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${entry.value} ошибок',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(Test test, List<TestAttempt> attempts) {
    if (attempts.isEmpty) {
      return {
        'totalAttempts': 0,
        'averageScore': 0,
        'completionRate': 0,
        'passRate': 0,
      };
    }

    final completed = attempts.where((a) => a.completedAt != null).length;
    final passed = attempts.where((a) => a.isPassed).length;
    final avgScore = attempts.fold<double>(0, (sum, a) => sum + a.percentage) / attempts.length;

    return {
      'totalAttempts': attempts.length,
      'averageScore': avgScore.round(),
      'completionRate': ((completed / attempts.length) * 100).round(),
      'passRate': ((passed / attempts.length) * 100).round(),
    };
  }

  void _exportToCSV(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Экспорт в CSV будет доступен в следующей версии',
          style: GoogleFonts.montserrat(),
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Простая модель теста
class RecentTest {
  final String id;
  final String title;
  final DateTime date;
  final int questions;

  RecentTest({
    required this.id,
    required this.title,
    required this.date,
    required this.questions,
  });
}

// Провайдер с мок-данными — возвращает небольшой список последних тестов
final recentTestsProvider = Provider<List<RecentTest>>((ref) {
  return [
    RecentTest(
      id: 't1',
      title: 'Математика — базовый уровень',
      date: DateTime.now().subtract(const Duration(days: 1)),
      questions: 15,
    ),
    RecentTest(
      id: 't2',
      title: 'Английский — грамматика',
      date: DateTime.now().subtract(const Duration(days: 3)),
      questions: 20,
    ),
    RecentTest(
      id: 't3',
      title: 'Логическое мышление',
      date: DateTime.now().subtract(const Duration(days: 5)),
      questions: 10,
    ),
  ];
});

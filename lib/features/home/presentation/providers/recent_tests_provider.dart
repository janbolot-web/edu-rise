import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/features/tests/data/repositories/test_repository.dart';
import 'package:edurise/features/tests/domain/models/test.dart' as domain;

// Простая модель теста для домашней страницы
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

  factory RecentTest.fromDomain(domain.Test t) {
    return RecentTest(
      id: t.id,
      title: t.title,
      date: t.createdAt,
      questions: t.questionCount,
    );
  }
}

// Провайдер, который загружает последние тесты из Firestore
final recentTestsProvider = FutureProvider<List<RecentTest>>((ref) async {
  final repo = TestRepository();
  final tests = await repo.getTests();
  return tests.map((t) => RecentTest.fromDomain(t)).toList();
});

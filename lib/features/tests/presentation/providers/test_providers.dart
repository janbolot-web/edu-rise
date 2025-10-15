import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/models/test.dart';
import '../../domain/models/test_attempt.dart';
import '../../domain/models/user_stats.dart';
import '../../data/repositories/test_repository.dart';

final testRepositoryProvider = Provider((ref) => TestRepository());

final testsProvider = FutureProvider.autoDispose.family<List<Test>, TestFilters>(
  (ref, filters) async {
    final repository = ref.read(testRepositoryProvider);
    return repository.getTests(
      subject: filters.subject,
      gradeLevel: filters.gradeLevel,
      difficulty: filters.difficulty,
      sortBy: filters.sortBy,
    );
  },
);

final testProvider = FutureProvider.autoDispose.family<Test?, String>(
  (ref, testId) async {
    final repository = ref.read(testRepositoryProvider);
    return repository.getTest(testId);
  },
);

final userAttemptsProvider = FutureProvider.autoDispose.family<List<TestAttempt>, String>(
  (ref, userId) async {
    final repository = ref.read(testRepositoryProvider);
    return repository.getUserAttempts(userId);
  },
);

final userStatsProvider = FutureProvider.autoDispose.family<UserTestStats?, String>(
  (ref, userId) async {
    final repository = ref.read(testRepositoryProvider);
    return repository.getUserStats(userId);
  },
);

final testAttemptsProvider = FutureProvider.autoDispose.family<List<TestAttempt>, String>(
  (ref, testId) async {
    final repository = ref.read(testRepositoryProvider);
    return repository.getTestAttempts(testId);
  },
);

class TestFilters {
  final String? subject;
  final int? gradeLevel;
  final TestDifficulty? difficulty;
  final String? sortBy;

  TestFilters({
    this.subject,
    this.gradeLevel,
    this.difficulty,
    this.sortBy = 'recent',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestFilters &&
          runtimeType == other.runtimeType &&
          subject == other.subject &&
          gradeLevel == other.gradeLevel &&
          difficulty == other.difficulty &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      subject.hashCode ^
      gradeLevel.hashCode ^
      difficulty.hashCode ^
      sortBy.hashCode;
}

final testFiltersProvider = StateProvider<TestFilters>((ref) => TestFilters());

// Note: Make sure flutter_riverpod is imported with StateProvider
// If using legacy.dart, use: import 'package:flutter_riverpod/legacy.dart';

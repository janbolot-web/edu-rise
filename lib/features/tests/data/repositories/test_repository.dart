import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/test.dart';
import '../../domain/models/test_attempt.dart';
import '../../domain/models/user_stats.dart';

class TestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Test>> getTests({
    String? subject,
    int? gradeLevel,
    TestDifficulty? difficulty,
    String? sortBy,
  }) async {
    try {
      print('\n🔍 [TestRepository] Fetching tests...');
      
      // ВРЕМЕННО: убираем фильтр по status, пока индекс не создан
      // Query query = _firestore
      //     .collection('tests')
      //     .where('status', isEqualTo: TestStatus.published.name);
      
      Query query = _firestore.collection('tests');

      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
        print('   📌 Filter by subject: $subject');
      }
      if (gradeLevel != null) {
        query = query.where('gradeLevel', isEqualTo: gradeLevel);
        print('   📌 Filter by grade: $gradeLevel');
      }
      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty.name);
        print('   📌 Filter by difficulty: ${difficulty.name}');
      }

      if (sortBy == 'popular') {
        query = query.orderBy('attempts', descending: true);
      } else if (sortBy == 'rating') {
        query = query.orderBy('averageScore', descending: true);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      print('   ⏳ Executing query...');
      final snapshot = await query.limit(50).get();
      print('   📦 Got ${snapshot.docs.length} documents from Firestore');
      
      final tests = snapshot.docs.map((doc) => Test.fromFirestore(doc)).toList();
      print('   ✅ Converted to ${tests.length} Test objects\n');
      
      return tests;
    } catch (e, stackTrace) {
      print('   ❌ Error fetching tests: $e');
      print('   Stack trace: $stackTrace\n');
      return [];
    }
  }

  Future<Test?> getTest(String testId) async {
    try {
      final doc = await _firestore.collection('tests').doc(testId).get();
      if (doc.exists) {
        return Test.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching test: $e');
      return null;
    }
  }

  Future<String> createTest(Test test) async {
    try {
      final docRef = await _firestore.collection('tests').add(test.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating test: $e');
      rethrow;
    }
  }

  Future<void> updateTest(Test test) async {
    try {
      await _firestore.collection('tests').doc(test.id).update(test.toJson());
    } catch (e) {
      print('Error updating test: $e');
      rethrow;
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      await _firestore.collection('tests').doc(testId).delete();
    } catch (e) {
      print('Error deleting test: $e');
      rethrow;
    }
  }

  Future<String> submitAttempt(TestAttempt attempt) async {
    try {
      final docRef =
          await _firestore.collection('testAttempts').add(attempt.toJson());
      
      await _firestore.collection('tests').doc(attempt.testId).update({
        'attempts': FieldValue.increment(1),
      });

      await _updateUserStats(attempt);
      
      return docRef.id;
    } catch (e) {
      print('Error submitting attempt: $e');
      rethrow;
    }
  }

  Future<List<TestAttempt>> getUserAttempts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('testAttempts')
          .where('userId', isEqualTo: userId)
          .orderBy('startedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => TestAttempt.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching user attempts: $e');
      return [];
    }
  }

  Future<List<TestAttempt>> getTestAttempts(String testId) async {
    try {
      final snapshot = await _firestore
          .collection('testAttempts')
          .where('testId', isEqualTo: testId)
          .orderBy('completedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => TestAttempt.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching test attempts: $e');
      return [];
    }
  }

  Future<UserTestStats?> getUserStats(String userId) async {
    try {
      final doc = await _firestore.collection('userTestStats').doc(userId).get();
      if (doc.exists) {
        return UserTestStats.fromFirestore(doc);
      }
      return UserTestStats(userId: userId);
    } catch (e) {
      print('Error fetching user stats: $e');
      return null;
    }
  }

  Future<void> _updateUserStats(TestAttempt attempt) async {
    try {
      final statsRef =
          _firestore.collection('userTestStats').doc(attempt.userId);
      final statsDoc = await statsRef.get();
      
      UserTestStats stats;
      if (statsDoc.exists) {
        stats = UserTestStats.fromFirestore(statsDoc);
      } else {
        stats = UserTestStats(userId: attempt.userId);
      }

      final newStreak = _calculateStreak(stats.lastTestDate);
      
      final updatedStats = UserTestStats(
        userId: attempt.userId,
        totalTests: stats.totalTests + 1,
        testsCompleted: stats.testsCompleted + (attempt.completedAt != null ? 1 : 0),
        testsPassed: stats.testsPassed + (attempt.isPassed ? 1 : 0),
        averageScore: ((stats.averageScore * stats.testsCompleted) + attempt.percentage) /
            (stats.testsCompleted + 1),
        totalPoints: stats.totalPoints + attempt.score,
        currentStreak: newStreak,
        longestStreak: newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
        lastTestDate: DateTime.now(),
        earnedBadges: _calculateBadges(stats, attempt),
        subjectScores: stats.subjectScores,
      );

      await statsRef.set(updatedStats.toJson());
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  int _calculateStreak(DateTime? lastTestDate) {
    if (lastTestDate == null) return 1;
    
    final now = DateTime.now();
    final lastDate = DateTime(lastTestDate.year, lastTestDate.month, lastTestDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(lastDate).inDays;
    
    if (difference == 0) return 1;
    if (difference == 1) return 1;
    return 1;
  }

  List<String> _calculateBadges(UserTestStats stats, TestAttempt attempt) {
    final badges = List<String>.from(stats.earnedBadges);
    
    if (stats.testsCompleted == 0 && !badges.contains('first_test')) {
      badges.add('first_test');
    }
    if (stats.testsCompleted + 1 >= 10 && !badges.contains('test_taker')) {
      badges.add('test_taker');
    }
    if (stats.testsCompleted + 1 >= 50 && !badges.contains('test_master')) {
      badges.add('test_master');
    }
    if (attempt.percentage == 100 && !badges.contains('perfectionist')) {
      badges.add('perfectionist');
    }
    
    return badges;
  }
}

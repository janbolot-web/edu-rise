import 'package:cloud_firestore/cloud_firestore.dart';

class UserTestStats {
  final String userId;
  final int totalTests;
  final int testsCompleted;
  final int testsPassed;
  final double averageScore;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastTestDate;
  final List<String> earnedBadges;
  final Map<String, int> subjectScores;

  UserTestStats({
    required this.userId,
    this.totalTests = 0,
    this.testsCompleted = 0,
    this.testsPassed = 0,
    this.averageScore = 0.0,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastTestDate,
    this.earnedBadges = const [],
    this.subjectScores = const {},
  });

  factory UserTestStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserTestStats.fromJson({...data, 'userId': doc.id});
  }

  factory UserTestStats.fromJson(Map<String, dynamic> json) {
    return UserTestStats(
      userId: json['userId'] as String,
      totalTests: json['totalTests'] as int? ?? 0,
      testsCompleted: json['testsCompleted'] as int? ?? 0,
      testsPassed: json['testsPassed'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastTestDate: json['lastTestDate'] != null
          ? (json['lastTestDate'] as Timestamp).toDate()
          : null,
      earnedBadges:
          (json['earnedBadges'] as List<dynamic>?)?.cast<String>() ?? [],
      subjectScores: json['subjectScores'] != null
          ? Map<String, int>.from(json['subjectScores'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalTests': totalTests,
      'testsCompleted': testsCompleted,
      'testsPassed': testsPassed,
      'averageScore': averageScore,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastTestDate':
          lastTestDate != null ? Timestamp.fromDate(lastTestDate!) : null,
      'earnedBadges': earnedBadges,
      'subjectScores': subjectScores,
    };
  }

  double get passRate =>
      testsCompleted > 0 ? (testsPassed / testsCompleted) * 100 : 0.0;
}

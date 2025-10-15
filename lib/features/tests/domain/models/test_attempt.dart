import 'package:cloud_firestore/cloud_firestore.dart';

class TestAttempt {
  final String id;
  final String testId;
  final String userId;
  final String userName;
  final Map<String, String> answers;
  final int score;
  final int totalPoints;
  final double percentage;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int timeSpent;
  final bool isPassed;
  final List<String> incorrectQuestions;

  TestAttempt({
    required this.id,
    required this.testId,
    required this.userId,
    required this.userName,
    required this.answers,
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.startedAt,
    this.completedAt,
    required this.timeSpent,
    required this.isPassed,
    required this.incorrectQuestions,
  });

  factory TestAttempt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestAttempt.fromJson({...data, 'id': doc.id});
  }

  factory TestAttempt.fromJson(Map<String, dynamic> json) {
    return TestAttempt(
      id: json['id'] as String,
      testId: json['testId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      answers: Map<String, String>.from(json['answers'] as Map),
      score: json['score'] as int,
      totalPoints: json['totalPoints'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      startedAt: (json['startedAt'] as Timestamp).toDate(),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      timeSpent: json['timeSpent'] as int,
      isPassed: json['isPassed'] as bool,
      incorrectQuestions:
          (json['incorrectQuestions'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testId': testId,
      'userId': userId,
      'userName': userName,
      'answers': answers,
      'score': score,
      'totalPoints': totalPoints,
      'percentage': percentage,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'timeSpent': timeSpent,
      'isPassed': isPassed,
      'incorrectQuestions': incorrectQuestions,
    };
  }
}

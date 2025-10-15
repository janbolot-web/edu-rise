import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';

enum TestDifficulty {
  easy,
  medium,
  hard,
}

enum TestStatus {
  draft,
  published,
  archived,
}

class Test {
  final String id;
  final String title;
  final String description;
  final String subject;
  final int gradeLevel;
  final TestDifficulty difficulty;
  final int duration;
  final List<Question> questions;
  final String teacherId;
  final String teacherName;
  final TestStatus status;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final int totalPoints;
  final int passingScore;
  final List<String> tags;
  final int attempts;
  final double averageScore;
  final String? coverImage;

  Test({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.gradeLevel,
    required this.difficulty,
    required this.duration,
    required this.questions,
    required this.teacherId,
    required this.teacherName,
    this.status = TestStatus.draft,
    required this.createdAt,
    this.publishedAt,
    int? totalPoints,
    this.passingScore = 70,
    this.tags = const [],
    this.attempts = 0,
    this.averageScore = 0.0,
    this.coverImage,
  }) : totalPoints = totalPoints ?? questions.fold(0, (sum, q) => sum + q.points);

  factory Test.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Test.fromJson({...data, 'id': doc.id});
  }

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      subject: json['subject'] as String,
      gradeLevel: json['gradeLevel'] as int,
      difficulty: TestDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => TestDifficulty.medium,
      ),
      duration: json['duration'] as int,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      status: TestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TestStatus.draft,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      publishedAt: json['publishedAt'] != null
          ? (json['publishedAt'] as Timestamp).toDate()
          : null,
      totalPoints: json['totalPoints'] as int?,
      passingScore: json['passingScore'] as int? ?? 70,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      attempts: json['attempts'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      coverImage: json['coverImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'difficulty': difficulty.name,
      'duration': duration,
      'questions': questions.map((q) => q.toJson()).toList(),
      'teacherId': teacherId,
      'teacherName': teacherName,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'totalPoints': totalPoints,
      'passingScore': passingScore,
      'tags': tags,
      'attempts': attempts,
      'averageScore': averageScore,
      'coverImage': coverImage,
    };
  }

  int get questionCount => questions.length;
}

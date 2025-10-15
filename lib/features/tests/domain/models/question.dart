
enum QuestionType {
  multipleChoice,
  trueFalse,
  shortAnswer,
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final int points;
  final String? imageUrl;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.points = 1,
    this.imageUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: (json['options'] as List<dynamic>?)?.cast<String>() ?? [],
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'points': points,
      'imageUrl': imageUrl,
    };
  }
}

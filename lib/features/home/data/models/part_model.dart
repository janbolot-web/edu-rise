import 'package:edurise/features/home/domain/entities/part_entity.dart';

class PartModel extends PartEntity {
  PartModel({
    required super.id,
    super.title,
    super.examples,
    super.description,
    super.imageUrl,
    super.sample,
    super.explanation,
    super.questions,
    super.descriptionPicture,
  });

  factory PartModel.fromMap(Map<String, dynamic> map) {
    return PartModel(
      id: '',
      title: '',
      examples: map['parts'] ?? [],
      description: '',
      imageUrl: [],
      sample: [],
      explanation: '',
      questions: [],
      descriptionPicture: map['description_picture'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      id: id,
      'title': title,
      'examples': examples,
      'description': description,
      'imageUrl': imageUrl,
      'sample': sample,
      'explanation': explanation,
      'questions': questions,
      'descriptionPicture': descriptionPicture,
    };
  }
}

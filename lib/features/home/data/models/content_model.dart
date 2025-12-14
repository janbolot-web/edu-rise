import 'package:edurise/features/home/domain/entities/content_entity.dart';

class ContentModel extends ContentEntity {
  ContentModel({
    required super.parts,
    required super.id,
    required super.title,
  });

  factory ContentModel.fromMap(Map<String, dynamic> map) {
    return ContentModel(
      parts: map['parts'] ?? [],
      id: '',
      title: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parts': parts, // Assuming Contents is a list
      id: id,
      title: title,
    };
  }
}

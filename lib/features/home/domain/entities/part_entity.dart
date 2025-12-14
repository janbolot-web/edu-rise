class PartEntity {
  final String id;
  final String? title;
  final String? description;
  final List? imageUrl;
  final List<dynamic>? examples;
  final List<dynamic>? sample;
  final String? explanation;
  final List<dynamic>? questions;
  final List? descriptionPicture;

  PartEntity({
    required this.id,
    this.title,
    this.examples,
    this.description,
    this.imageUrl,
    this.sample,
    this.explanation,
    this.questions,
    this.descriptionPicture,
  });
}

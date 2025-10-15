// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Course _$CourseFromJson(Map<String, dynamic> json) => _Course(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String,
  author: json['author'] as String,
  rating: (json['rating'] as num).toDouble(),
  lessonsCount: (json['lessonsCount'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  modules:
      (json['modules'] as List<dynamic>?)
          ?.map((e) => CourseModule.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  gradientColors:
      (json['gradientColors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$CourseToJson(_Course instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'author': instance.author,
  'rating': instance.rating,
  'lessonsCount': instance.lessonsCount,
  'price': instance.price,
  'modules': instance.modules.map((e) => e.toJson()).toList(),
  'gradientColors': instance.gradientColors,
};

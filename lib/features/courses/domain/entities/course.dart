import 'package:freezed_annotation/freezed_annotation.dart';
import 'module.dart';

part 'course.freezed.dart';
part 'course.g.dart';

@freezed
abstract class Course with _$Course {
  const factory Course({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required String author,
    required double rating,
    required int lessonsCount,
  required double price,
  @Default([]) List<CourseModule> modules,
  @Default([]) List<String> gradientColors,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}

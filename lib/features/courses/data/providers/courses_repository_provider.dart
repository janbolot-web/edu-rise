import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/features/courses/domain/repositories/courses_repository.dart';
import 'package:edurise/features/courses/data/repositories/courses_repository_impl.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return CoursesRepositoryImpl();
});

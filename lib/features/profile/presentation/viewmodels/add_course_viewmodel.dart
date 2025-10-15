import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/features/courses/domain/repositories/courses_repository.dart';
import 'package:edurise/di/providers.dart';

final addCourseViewModelProvider = Provider((ref) {
  final repo = ref.read(coursesRepositoryProvider);
  return AddCourseViewModel(repo);
});

class AddCourseViewModel {
  final CoursesRepository _repo;
  AddCourseViewModel(this._repo);

  Future<void> addCourse(Map<String, dynamic> data) async {
    await _repo.addCourse(data);
  }
}

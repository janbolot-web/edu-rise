import 'package:edurise/features/courses/domain/entities/course.dart';

abstract class CoursesRepository {
  /// Возвращает поток списка курсов
  Stream<List<Course>> watchCourses();

  /// Добавляет новый курс в хранилище
  Future<void> addCourse(Map<String, dynamic> courseData);
}

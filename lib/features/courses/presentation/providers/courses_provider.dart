import 'package:edurise/di/providers.dart';
import 'package:edurise/features/courses/domain/entities/course.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final courses = ref.watch(coursesProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  
  return courses.whenData((coursesList) {
    if (searchQuery.isEmpty) return coursesList;
    
    return coursesList.where((course) {
      return course.title.toLowerCase().contains(searchQuery) ||
             course.description.toLowerCase().contains(searchQuery) ||
             course.author.toLowerCase().contains(searchQuery);
    }).toList();
  });
});

final coursesProvider = StreamProvider<List<Course>>((ref) {
  final repository = ref.watch(coursesRepositoryProvider);
  return repository.watchCourses();
});

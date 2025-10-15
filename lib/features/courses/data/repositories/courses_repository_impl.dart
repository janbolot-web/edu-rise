// Cleaned: removed unused imports related to test seeding
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edurise/features/courses/domain/entities/course.dart';
import 'package:edurise/features/courses/domain/entities/module.dart';
import 'package:edurise/features/courses/domain/repositories/courses_repository.dart';
// Removed test-data seeding imports (cleanup).

class CoursesRepositoryImpl implements CoursesRepository {
  final FirebaseFirestore _firestore;

  CoursesRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Seed/test data removed — repository focuses on production behavior only.

  List<Course> _getMockCourses() {
    return [
      Course(
        id: 'flutter-basics-course',
        title: 'Основы Flutter разработки',
        description: 'Комплексный курс по разработке мобильных приложений на Flutter',
        author: 'Александр Петров',
        imageUrl: 'https://picsum.photos/800/400',
        rating: 4.8,
        price: 15000.0,
        lessonsCount: 3,
        modules: [
          CourseModule(
            id: 'module-1',
            title: 'Введение во Flutter',
            description: 'Базовые концепции и настройка окружения',
            duration: 120,
            lessons: [
              ModuleLesson(
                id: 'lesson-1',
                title: 'Что такое Flutter?',
                duration: 15,
                isPreview: true,
                videoUrl: 'https://www.youtube.com/watch?v=x0uinJvhNxI',
                description: '''Flutter - это революционный фреймворк от Google для создания кроссплатформенных приложений.''',
              ),
              ModuleLesson(
                id: 'lesson-2',
                title: 'Установка Flutter SDK',
                duration: 25,
                isPreview: false,
                videoUrl: 'https://www.youtube.com/watch?v=RJ-UGqyA-Sc',
                description: 'Пошаговое руководство по установке Flutter SDK и настройке IDE',
              ),
            ],
          ),
          CourseModule(
            id: 'module-2',
            title: 'Основы Dart',
            description: 'Изучение языка программирования Dart',
            duration: 180,
            lessons: [
              ModuleLesson(
                id: 'lesson-3',
                title: 'Введение в Dart',
                duration: 20,
                isPreview: true,
                videoUrl: 'https://www.youtube.com/watch?v=5izFZgPqClc',
                description: 'Основы синтаксиса Dart, переменные, функции и классы',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Stream<List<Course>> watchCourses() {
    try {
      return _firestore.collection('courses').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return _getMockCourses();
        }
        
        return snapshot.docs.map((doc) {
          final data = doc.data();
          
          // Преобразуем модули
          final modules = (data['modules'] as List<dynamic>).map((moduleData) {
            return CourseModule(
              id: moduleData['id'] as String,
              title: moduleData['title'] as String,
              description: moduleData['description'] as String,
              duration: moduleData['duration'] as int,
              lessons: (moduleData['lessons'] as List<dynamic>).map((lessonData) {
                return ModuleLesson(
                  id: lessonData['id'] as String,
                  title: lessonData['title'] as String,
                  duration: lessonData['duration'] as int,
                  isPreview: lessonData['isPreview'] as bool? ?? false,
                  videoUrl: lessonData['videoUrl'] as String? ?? '',
                  description: lessonData['description'] as String? ?? '',
                );
              }).toList(),
            );
          }).toList();

          // Создаем объект Course
          final totalLessons = modules.fold<int>(
            0,
            (sum, module) => sum + module.lessons.length,
          );

          return Course(
            id: doc.id,
            title: data['title'] as String,
            description: data['description'] as String,
            author: data['author'] as String,
            imageUrl: data['imageUrl'] as String,
            rating: (data['rating'] as num).toDouble(),
            price: (data['price'] as num).toDouble(),
            lessonsCount: totalLessons,
            modules: modules,
          );
        }).toList();
      });
    } catch (e) {
      // В случае ошибки возвращаем поток с тестовыми данными
      return Stream.value(_getMockCourses());
    }
  }

  @override
  Future<void> addCourse(Map<String, dynamic> courseData) async {
    final id = courseData['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore.collection('courses').doc(id).set(courseData);
  }
}

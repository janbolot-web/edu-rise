import 'package:edurise/di/providers.dart';
import 'package:edurise/features/courses/domain/entities/course.dart';
import 'package:edurise/features/courses/domain/entities/module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CourseWithGradient {
  final Course course;
  final List<String> gradientColors; // list of hex strings like ['#FFAC71', '#FF8450']

  CourseWithGradient({required this.course, required this.gradientColors});
}

final coursesWithGradientProvider = StreamProvider<List<CourseWithGradient>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  try {
    return firestore.collection('courses').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return <CourseWithGradient>[];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();

        // parse modules if present
        final modules = (data['modules'] as List<dynamic>? ?? [])
            .map((moduleData) {
          return CourseModule(
            id: moduleData['id'] as String,
            title: moduleData['title'] as String,
            description: moduleData['description'] as String,
            duration: moduleData['duration'] as int,
            lessons: (moduleData['lessons'] as List<dynamic>? ?? []).map((lessonData) {
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

        final totalLessons = modules.fold<int>(0, (sum, m) => sum + m.lessons.length);

        final course = Course(
          id: doc.id,
          title: data['title'] as String? ?? '',
          description: data['description'] as String? ?? '',
          author: data['author'] as String? ?? '',
          imageUrl: data['imageUrl'] as String? ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          lessonsCount: totalLessons,
          modules: modules,
        );

        final gradientRaw = data['gradientColors'] ?? data['gradient'] ?? data['gradient_color'];
        List<String> gradient = [];
        if (gradientRaw is List) {
          gradient = gradientRaw.map((e) => e.toString()).toList();
        } else if (gradientRaw is String) {
          // allow comma-separated
          gradient = gradientRaw.split(',').map((s) => s.trim()).toList();
        }

        return CourseWithGradient(course: course, gradientColors: gradient);
      }).toList();
    });
  } catch (e) {
    return Stream.value(<CourseWithGradient>[]);
  }
});

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edurise/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:edurise/features/courses/domain/repositories/courses_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_api_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Ai API service provider (OpenAI)
final aiApiServiceProvider = Provider<AiApiService>((ref) {
  return AiApiService(
    apiKey: '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',
    endpoint: null,
  );
});

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return CoursesRepositoryImpl(firestore: firestore);
});

/// Async provider that performs a tiny read/write to Firestore to verify connectivity.
final firestorePingProvider = FutureProvider<bool>((ref) async {
  final firestore = ref.read(firestoreProvider);
  final doc = firestore.collection('__ping__').doc('ping');
  try {
    await doc.set({'ts': DateTime.now().toIso8601String()});
    final snap = await doc.get();
    return snap.exists;
  } catch (e) {
    return false;
  }
});

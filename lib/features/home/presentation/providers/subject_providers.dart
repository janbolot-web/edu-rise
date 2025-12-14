import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edurise/features/home/data/datasources/subject_remote_ds.dart';
import 'package:edurise/features/home/data/repositories/subject_repository_impl.dart';
import 'package:edurise/features/home/domain/repositories/subject_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/features/home/domain/entities/subjects_entity.dart';

final subjectRepoProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepositoryImpl(
    SubjectRemoteDataSource(FirebaseFirestore.instance),
  );
});

final getSubjectProvider = FutureProvider.family<SubjectEntity, String>((ref, String id) {
  final repo = ref.watch(subjectRepoProvider);
  return repo.getSubject(id);
});

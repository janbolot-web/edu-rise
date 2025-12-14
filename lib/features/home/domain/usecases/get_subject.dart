import 'package:edurise/features/home/domain/entities/subjects_entity.dart';
import 'package:edurise/features/home/domain/repositories/subject_repository.dart';

class GetSubject {
  final SubjectRepository repository;

  GetSubject(this.repository);

  Future<SubjectEntity> call(String id) {
    return repository.getSubject(id);
  }
}

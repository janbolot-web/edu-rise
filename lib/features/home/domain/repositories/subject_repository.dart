import 'package:edurise/features/home/domain/entities/subjects_entity.dart';

abstract class SubjectRepository {
  Future<SubjectEntity> getSubject(String id);
}

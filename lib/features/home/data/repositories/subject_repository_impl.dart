import 'package:edurise/features/home/data/datasources/subject_remote_ds.dart';
import 'package:edurise/features/home/domain/entities/subjects_entity.dart';
import 'package:edurise/features/home/domain/repositories/subject_repository.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectRemoteDataSource remoteDataSource;

  SubjectRepositoryImpl(this.remoteDataSource);

  @override
  Future<SubjectEntity> getSubject(String id) async {
    return await remoteDataSource.getSubject(id);
  }
}

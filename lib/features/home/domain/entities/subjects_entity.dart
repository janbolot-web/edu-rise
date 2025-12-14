import 'package:edurise/features/home/domain/entities/stage_entity.dart';

class SubjectEntity {
  final String id;
  final String title;
  final List<StageEntity> stages;

  SubjectEntity({
    required this.id,
    required this.title,
    required this.stages,
  });
}

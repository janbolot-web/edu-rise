import 'package:edurise/features/home/domain/entities/subjects_entity.dart';
import 'package:edurise/features/home/data/models/stage_model.dart';
import 'package:edurise/features/home/domain/entities/stage_entity.dart';

class SubjectModel extends SubjectEntity {
  SubjectModel({
    required super.id,
    required super.stages,
    required super.title,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map, String id) {
    final stagesRaw = map['stages'] as List<dynamic>?;
    final stages =
        stagesRaw
            ?.map(
              (e) => StageModel.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        <dynamic>[];

    return SubjectModel(
      id: id,
      stages: stages.cast<StageEntity>(),
      title: map['title']?.toString() ?? '',
    );
  }
  
}

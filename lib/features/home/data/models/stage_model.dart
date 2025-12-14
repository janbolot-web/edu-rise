import 'package:edurise/features/home/domain/entities/stage_entity.dart';

class StageModel extends StageEntity {
  StageModel({ required super.name, required super.modules});

  factory StageModel.fromMap(Map<String, dynamic> map) {
    return StageModel(
      name: map['name'],
      modules: map['modules'] ?? [], // Assuming modules is a list
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'modules': modules, // Assuming modules is a list
    };
  }
}

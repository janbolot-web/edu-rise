import 'package:edurise/features/home/domain/entities/module_entity.dart';

class ModuleModel extends ModuleEntity {
  ModuleModel({ required super.contents, required super.id, required super.title});

  factory ModuleModel.fromMap(Map<String, dynamic> map) {
    return ModuleModel(
      contents: map['contents'] ?? [], id: '', title: '', // Assuming modules is a list
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contents': contents, // Assuming modules is a list
      id: id,
      title: title,
    };
  }
}

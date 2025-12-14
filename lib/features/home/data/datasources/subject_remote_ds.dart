import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edurise/features/home/data/models/subject_model.dart';

class SubjectRemoteDataSource {
  final FirebaseFirestore firestore;

  SubjectRemoteDataSource(this.firestore);

  Future<SubjectModel> getSubject(String id) async {
    final doc = await firestore.collection('subjects').doc(id).get();

    if (!doc.exists) {
      throw Exception("Subject not found: $id");
    }

    return SubjectModel.fromMap(doc.data()!, doc.id);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edurise/features/tests/domain/models/answer_sheet_template.dart';

class AnswerSheetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'answer_sheet_templates';

  Future<void> saveTemplate(AnswerSheetTemplate template) async {
    await _firestore.collection(_collection).doc(template.id).set(template.toJson());
  }

  Future<AnswerSheetTemplate?> getTemplateByBarcode(String barcodeData) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('barcodeData', isEqualTo: barcodeData)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return AnswerSheetTemplate.fromJson(querySnapshot.docs.first.data());
  }

  Future<List<AnswerSheetTemplate>> getTemplatesByUser(String userId) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => AnswerSheetTemplate.fromJson(doc.data()))
        .toList();
  }
}

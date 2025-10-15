import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PurchaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<bool> purchaseCourse(String courseId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Имитация процесса оплаты
      await Future.delayed(const Duration(seconds: 2));

      // Записываем информацию о покупке
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('purchases')
          .doc(courseId)
          .set({
        'purchaseDate': FieldValue.serverTimestamp(),
        'status': 'completed',
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

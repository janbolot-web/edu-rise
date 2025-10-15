import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final purchasedCoursesProvider = StreamProvider<List<String>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('purchases')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
});

final courseIsPurchasedProvider = StreamProvider.family<bool, String>((ref, courseId) {
  final purchasedCoursesStream = ref.watch(purchasedCoursesProvider);
  return purchasedCoursesStream.when(
    data: (purchasedCourses) => Stream.value(purchasedCourses.contains(courseId)),
    error: (_, __) => Stream.value(false),
    loading: () => Stream.value(false),
  );
});

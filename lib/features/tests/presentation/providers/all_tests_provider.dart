import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/test.dart';

// Провайдер который показывает ВСЕ тесты без фильтра
final allTestsProvider = FutureProvider<List<Test>>((ref) async {
  print('🔥 [AllTests] Fetching ALL tests from Firestore...');
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Берем ВСЕ тесты без фильтра по status
    final snapshot = await firestore
        .collection('tests')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    
    print('🔥 [AllTests] Got ${snapshot.docs.length} documents');
    
    final tests = <Test>[];
    
    for (var doc in snapshot.docs) {
      try {
        final data = doc.data();
        print('   📄 ${data['title']} - status: ${data['status']}');
        
        final test = Test.fromFirestore(doc);
        tests.add(test);
      } catch (e) {
        print('   ⚠️  Error parsing test ${doc.id}: $e');
      }
    }
    
    print('🔥 [AllTests] Successfully parsed ${tests.length} tests\n');
    return tests;
    
  } catch (e, stackTrace) {
    print('❌ [AllTests] Error: $e');
    print('Stack: $stackTrace\n');
    return [];
  }
});

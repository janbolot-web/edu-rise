import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';

class TestFirestoreCheck extends StatefulWidget {
  const TestFirestoreCheck({super.key});

  @override
  State<TestFirestoreCheck> createState() => _TestFirestoreCheckState();
}

class _TestFirestoreCheckState extends State<TestFirestoreCheck> {
  String _result = '';
  bool _loading = false;

  Future<void> _checkTests() async {
    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      // 1. Проверяем ВСЕ документы
      print('\n========== FIRESTORE CHECK ==========');
      final allDocs = await firestore.collection('tests').get();
      print('📦 Всего документов в коллекции: ${allDocs.docs.length}');
      
      String report = '📦 Всего документов: ${allDocs.docs.length}\n\n';
      
      for (var doc in allDocs.docs) {
        final data = doc.data();
        print('\n--- Документ: ${doc.id} ---');
        print('  title: ${data['title']}');
        print('  status: ${data['status']}');
        print('  subject: ${data['subject']}');
        
        report += '📄 ${data['title']}\n';
        report += '   ID: ${doc.id}\n';
        report += '   Status: ${data['status']}\n';
        report += '   Subject: ${data['subject']}\n\n';
      }
      
      // 2. Проверяем query как в репозитории
      print('\n--- Проверяем query с фильтром status=published ---');
      final publishedDocs = await firestore
          .collection('tests')
          .where('status', isEqualTo: 'published')
          .get();
      print('📗 Опубликованных: ${publishedDocs.docs.length}');
      
      report += '\n✅ Опубликованных (status=published): ${publishedDocs.docs.length}\n\n';
      
      for (var doc in publishedDocs.docs) {
        final data = doc.data();
        report += '  ✓ ${data['title']}\n';
      }
      
      // 3. Проверяем без фильтра
      print('\n--- Проверяем без фильтра ---');
      final noFilterDocs = await firestore
          .collection('tests')
          .limit(10)
          .get();
      print('📘 Без фильтра (первые 10): ${noFilterDocs.docs.length}');
      
      report += '\n\n📘 Без фильтра (первые 10): ${noFilterDocs.docs.length}\n';
      
      // 4. Проверяем поля каждого документа
      if (allDocs.docs.isNotEmpty) {
        print('\n--- Детальная проверка первого документа ---');
        final firstDoc = allDocs.docs.first;
        final data = firstDoc.data();
        
        report += '\n\n🔍 Детали первого теста:\n';
        
        final requiredFields = [
          'title', 'description', 'subject', 'gradeLevel', 
          'difficulty', 'duration', 'teacherId', 'teacherName',
          'status', 'createdAt', 'questions'
        ];
        
        for (var field in requiredFields) {
          final hasField = data.containsKey(field);
          final value = hasField ? data[field] : null;
          print('  $field: ${hasField ? "✓" : "✗"} = $value');
          
          report += '  ${hasField ? "✅" : "❌"} $field: ${value ?? "ОТСУТСТВУЕТ"}\n';
        }
      }
      
      print('\n========== END CHECK ==========\n');
      
      setState(() {
        _result = report;
        _loading = false;
      });
      
    } catch (e, stack) {
      print('❌ Ошибка: $e');
      print(stack);
      setState(() {
        _result = '❌ Ошибка: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appPrimary,
        title: Text(
          'Проверка Firestore',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔍 Диагностика Firestore',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: appPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Проверяем почему тесты не отображаются',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: appSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _checkTests,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search, color: Colors.white),
              label: Text(
                _loading ? 'Проверяем...' : 'Проверить Firestore',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: appAccentEnd,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),
          ),
          if (_result.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    _result,
                    style: GoogleFonts.robotoMono(
                      fontSize: 13,
                      color: appPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

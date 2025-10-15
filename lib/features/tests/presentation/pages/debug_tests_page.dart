import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';

class DebugTestsPage extends StatefulWidget {
  const DebugTestsPage({super.key});

  @override
  State<DebugTestsPage> createState() => _DebugTestsPageState();
}

class _DebugTestsPageState extends State<DebugTestsPage> {
  String _status = 'Готов к проверке';
  List<Map<String, dynamic>> _tests = [];

  Future<void> _checkFirestore() async {
    setState(() => _status = 'Проверяю Firestore...');

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Проверяем все тесты
      final allTests = await firestore.collection('tests').get();
      setState(() {
        _status = 'Найдено ${allTests.docs.length} тестов в коллекции';
        _tests = allTests.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? 'Без названия',
            'status': data['status'] ?? 'unknown',
            'subject': data['subject'] ?? 'Не указано',
          };
        }).toList();
      });

      // Проверяем опубликованные
      final published = await firestore
          .collection('tests')
          .where('status', isEqualTo: 'published')
          .get();
      
      print('📊 Всего тестов: ${allTests.docs.length}');
      print('📊 Опубликовано: ${published.docs.length}');
      
    } catch (e) {
      setState(() => _status = 'Ошибка: $e');
      print('❌ Ошибка при проверке: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appPrimary,
        title: Text(
          'Отладка тестов',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статус:',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: appPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: appPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _checkFirestore,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Проверить Firestore',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: appAccentEnd,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (_tests.isNotEmpty) ...[
              Text(
                'Найденные тесты:',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: appPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _tests.length,
                  itemBuilder: (context, index) {
                    final test = _tests[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test['title'],
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: appPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: test['status'] == 'published'
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  test['status'],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: test['status'] == 'published'
                                        ? Colors.green.shade900
                                        : Colors.orange.shade900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                test['subject'],
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: appSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${test['id']}',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: appSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

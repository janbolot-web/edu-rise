import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/test_data_samples.dart';

class TestDataLoaderPage extends StatefulWidget {
  const TestDataLoaderPage({super.key});

  @override
  State<TestDataLoaderPage> createState() => _TestDataLoaderPageState();
}

class _TestDataLoaderPageState extends State<TestDataLoaderPage> {
  bool _isLoading = false;
  String _message = '';

  Future<void> _loadSampleData() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _message = '❌ Необходимо войти в систему';
          _isLoading = false;
        });
        return;
      }

      await TestDataSamples.createSampleTests(
        user.uid,
        user.displayName ?? 'Тестовый учитель',
      );

      setState(() {
        _message = '✅ Тестовые данные успешно загружены!\n\n'
            '📚 Создано 4 теста:\n'
            '• Математика - Дроби (5 вопросов)\n'
            '• Русский язык - Глаголы (6 вопросов)\n'
            '• English - Present Simple (5 вопросов)\n'
            '• Физика - Законы Ньютона (5 вопросов)';
        _isLoading = false;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      setState(() {
        _message = '❌ Ошибка: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Загрузка тестовых данных',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: appPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: appPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appAccentStart, appAccentEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.science,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Создать тестовые тесты',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Загрузите 4 готовых теста для проверки функциональности',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Что будет создано:',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: appPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTestItem(
                    '📐 Математика 5 класс',
                    'Обыкновенные дроби - 5 вопросов',
                    'Легкий • 15 минут',
                  ),
                  _buildTestItem(
                    '📚 Русский язык 6 класс',
                    'Глаголы - 6 вопросов',
                    'Средний • 20 минут',
                  ),
                  _buildTestItem(
                    '🇬🇧 English 7 класс',
                    'Present Simple - 5 вопросов',
                    'Средний • 25 минут',
                  ),
                  _buildTestItem(
                    '⚡ Физика 9 класс',
                    'Законы Ньютона - 5 вопросов',
                    'Сложный • 30 минут',
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _message.startsWith('✅')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _message.startsWith('✅')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Text(
                  _message,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: _message.startsWith('✅')
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _loadSampleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: appAccentEnd,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Создать тестовые тесты',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestItem(String title, String subtitle, String meta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: appAccentEnd,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: appSecondary,
                  ),
                ),
                Text(
                  meta,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: appSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

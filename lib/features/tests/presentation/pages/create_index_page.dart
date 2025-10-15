import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class CreateIndexPage extends StatelessWidget {
  const CreateIndexPage({super.key});

  static const indexUrl =
      'https://console.firebase.google.com/v1/r/project/edurise-3fec9/firestore/indexes?create_composite=Cktwcm9qZWN0cy9lZHVyaXNlLTNmZWM5L2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy90ZXN0cy9pbmRleGVzL18QARoKCgZzdGF0dXMQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appPrimary,
        title: Text(
          'Создать индекс',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.red.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Требуется индекс Firestore',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Чтобы тесты отображались, нужно создать составной индекс',
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
                    '⚡ Быстрое решение (30 секунд):',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: appPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStep('1️⃣', 'Нажмите кнопку "Открыть Firebase"'),
                  _buildStep('2️⃣', 'Нажмите "Create Index" в Firebase'),
                  _buildStep('3️⃣', 'Подождите 1-2 минуты'),
                  _buildStep('4️⃣', 'Перезапустите приложение'),
                  _buildStep('✅', 'Тесты появятся!'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _launchUrl(context),
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              label: Text(
                'Открыть Firebase Console',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: appAccentEnd,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _copyUrl(context),
              icon: const Icon(Icons.copy),
              label: Text(
                'Скопировать ссылку',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Почему это нужно?',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: appPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Firestore требует составные индексы для запросов с фильтрацией и сортировкой по разным полям.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: appPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Наш запрос:\n'
                    '• Фильтр: status == "published"\n'
                    '• Сортировка: createdAt (desc)\n\n'
                    'Требуется индекс: status + createdAt',
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: appPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse(indexUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Не удалось открыть браузер. Скопируйте ссылку вручную.',
              style: GoogleFonts.montserrat(),
            ),
            action: SnackBarAction(
              label: 'Копировать',
              onPressed: () => _copyUrl(context),
            ),
          ),
        );
      }
    }
  }

  void _copyUrl(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: indexUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ссылка скопирована! Откройте в браузере',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

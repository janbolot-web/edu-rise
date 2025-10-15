import 'package:edurise/di/ai_api_service.dart';

void main() async {
  final service = AiApiService(apiKey: 'AIzaSyDn-eFWwb-55TKCeuK-qQYs2GE7YKeXrN0');
  
  try {
    print('Отправка тестового запроса к Gemini API...');
    final response = await service.generate('Напиши короткий тест для проверки API на русском языке');
    print('\nОтвет от API:\n$response');
  } catch (e) {
    print('Ошибка при запросе к API: $e');
  }
}

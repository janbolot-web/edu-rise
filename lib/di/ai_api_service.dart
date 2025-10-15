import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Результат генерации изображения: либо сытые байты, либо URL к изображению.
class ImageResult {
  final Uint8List? bytes;
  final String? url;
  ImageResult({this.bytes, this.url});
  bool get hasBytes => bytes != null;
  bool get hasUrl => url != null && url!.isNotEmpty;
}

/// Результат генерации аудио: байты аудиофайла.
class AudioResult {
  final Uint8List bytes;
  AudioResult({required this.bytes});
}

// OpenAI endpoints
const String _openAiChatCompletions = 'https://openrouter.ai/api/v1/chat/completions';

class AiApiService {
  final String? apiKey;
  final String? endpoint; // legacy
  AiApiService({this.apiKey, String? endpoint}) : endpoint = endpoint;

  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;

  Stream<String> generateStream(String prompt) async* {
    if (!isConfigured) throw Exception('AI API not configured');
    final url = Uri.parse(_openAiChatCompletions);
    final request = http.Request('POST', url);
    request.headers['Content-Type'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.headers['Accept'] = 'text/event-stream, application/json';
    request.body = jsonEncode({
      'model': 'openai/gpt-5-chat',
      'stream': true,
      'messages': [
        {
          'role': 'user',
          'content': prompt
        }
      ],
      'temperature': 0.7
    });

    final streamedResponse = await http.Client().send(request);
    String accumulatedText = '';

    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      // Buffer for partial SSE segments
      var buffer = '';
      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        // Debug: log chunk length and prefix
        try {
          // debug chunk logging removed for production
        } catch (_) {}
        buffer += chunk;

        // Try SSE parsing: segments separated by double newline
        var segments = buffer.split('\n\n');
        // keep last partial segment in buffer
        buffer = segments.isNotEmpty ? segments.removeLast() : '';

        for (var seg in segments) {
          seg = seg.trim();
          if (seg.isEmpty) continue;
          // Each segment may contain lines starting with "data: "
          for (var line in seg.split('\n')) {
            line = line.trim();
            if (line.isEmpty) continue;
            if (line.startsWith('data:')) {
              var data = line.substring(5).trim();
              if (data == '[DONE]') continue;
              try {
                final parsed = jsonDecode(data);
                // 1) Стриминговый дельта-токен
                final deltaPiece = _extractOpenAiDelta(parsed);
                if (deltaPiece != null && deltaPiece.isNotEmpty) {
                  // Для стрима отдаём токен напрямую, без substring-магии
                  accumulatedText += deltaPiece;
                  yield deltaPiece;
                  continue;
                }
                // 2) Не-стримовый ответ (иногда сервер может прислать полный JSON)
                final extracted = _extractTextFromResponse(parsed) ?? _deepFindText(parsed);
                if (extracted != null && extracted.isNotEmpty) {
                  final newText = extracted.substring(accumulatedText.length);
                  if (newText.isNotEmpty) {
                    accumulatedText = extracted;
                    yield newText;
                  }
                }
                } catch (e) {
                print('Ошибка парсинга JSON: $e');
                continue;
              }
            } else {
              // Fallback: try to parse the line itself as JSON
              try {
                final parsed = jsonDecode(line);
                final deltaPiece = _extractOpenAiDelta(parsed);
                if (deltaPiece != null && deltaPiece.isNotEmpty) {
                  accumulatedText += deltaPiece;
                  yield deltaPiece;
                } else {
                  final extracted = _extractTextFromResponse(parsed) ?? _deepFindText(parsed);
                  if (extracted != null && extracted.isNotEmpty) {
                    final newText = extracted.substring(accumulatedText.length);
                    if (newText.isNotEmpty) {
                      accumulatedText = extracted;
                      yield newText;
                    }
                  }
                }
              } catch (e) {
                // not JSON line, skip
                continue;
              }
            }
          }
        }

        // Also try fallback: if buffer looks like a complete JSON (no SSE), parse it
        if (buffer.isNotEmpty) {
          final trimmed = buffer.trim();
          if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
            try {
              final parsed = jsonDecode(trimmed);
              final deltaPiece = _extractOpenAiDelta(parsed);
              if (deltaPiece != null && deltaPiece.isNotEmpty) {
                accumulatedText += deltaPiece;
                yield deltaPiece;
                buffer = '';
              } else {
                final extracted = _extractTextFromResponse(parsed) ?? _deepFindText(parsed);
                if (extracted != null && extracted.isNotEmpty) {
                  final newText = extracted.substring(accumulatedText.length);
                  if (newText.isNotEmpty) {
                    accumulatedText = extracted;
                    yield newText;
                  }
                  buffer = '';
                }
              }
            } catch (e) {
              // not a full JSON yet
            }
          }
        }
      }
    } else {
      final errorBody = await streamedResponse.stream.transform(utf8.decoder).join();
      throw Exception('AI API error: ${streamedResponse.statusCode} - $errorBody');
    }
  }

  // Helper: try to extract generated text from known response shapes
  String? _extractTextFromResponse(dynamic json) {
    try {
      if (json is Map) {
        // OpenAI chat completions non-stream
        if (json['choices'] != null && json['choices'] is List && (json['choices'] as List).isNotEmpty) {
          final first = (json['choices'] as List).first;
          final message = first['message'];
          if (message != null) {
            if (message['content'] is String) return message['content'] as String;
            if (message['content'] is List) {
              final parts = message['content'] as List;
              final text = parts.map((e) => e is Map && e['type'] == 'text' ? (e['text'] ?? '') : '').join();
              if (text.isNotEmpty) return text;
            }
          }
        }
      }
    } catch (e) {
      // extractText error logging removed
    }
    return null;
  }

  // Extract OpenAI streaming delta text
  String? _extractOpenAiDelta(dynamic json) {
    try {
      if (json is Map && json['choices'] != null) {
        final choices = json['choices'] as List;
        if (choices.isNotEmpty) {
          final delta = choices.first['delta'];
          if (delta != null && delta['content'] is String) {
            return delta['content'] as String;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // Deep search for any 'text' keys inside nested maps/lists
  String? _deepFindText(dynamic node) {
    try {
      if (node is Map) {
        if (node.containsKey('text') && node['text'] is String) {
          return node['text'] as String;
        }
        String accum = '';
        for (var v in node.values) {
          final found = _deepFindText(v);
          if (found != null && found.isNotEmpty) accum += found;
        }
        return accum.isNotEmpty ? accum : null;
      } else if (node is List) {
        String accum = '';
        for (var item in node) {
          final found = _deepFindText(item);
          if (found != null && found.isNotEmpty) accum += found;
        }
        return accum.isNotEmpty ? accum : null;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // Removed regex fallback (не используется)

  Future<String> generate(String prompt) async {
    if (!isConfigured) throw Exception('AI API not configured');
    final url = Uri.parse(_openAiChatCompletions);
    final resp = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'openai/gpt-5-chat',
          'messages': [
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.7
        }));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = jsonDecode(resp.body);
      final text = _extractTextFromResponse(body);
      if (text != null && text.isNotEmpty) return text;
      throw Exception('Неожиданный формат ответа от API: ${body.toString()}');
    }
    throw Exception('AI API error: ${resp.statusCode} ${resp.body}');
  }

  /// Простая обёртка для генерации изображения по текстовому промпту.
  /// Использует бесплатный API pollinations.ai с моделью nanobanana
  /// Возвращает bytes изображения (PNG/JPEG) или выбрасывает исключение.
  Future<ImageResult> generateImageBytes(String prompt, {String size = '1024x1024'}) async {
    // Парсим размер (формат: "1024x1024")
    final parts = size.split('x');
    final width = parts.isNotEmpty ? parts[0] : '1024';
    final height = parts.length > 1 ? parts[1] : '1024';
    
    // Кодируем prompt для URL
    final encodedPrompt = Uri.encodeComponent(prompt);
    
    // Формируем URL для pollinations.ai
    final url = Uri.parse('https://image.pollinations.ai/prompt/$encodedPrompt?width=$width&height=$height&nologo=true');
    
    try {
      // Отправляем GET запрос для получения изображения
      final resp = await http.get(url);
      
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // API возвращает изображение напрямую в виде байтов
        if (resp.bodyBytes.isNotEmpty) {
          return ImageResult(bytes: resp.bodyBytes);
        }
        throw Exception('Empty image response');
      }
      throw Exception('Image API error: ${resp.statusCode}');
    } catch (e) {
      throw Exception('Failed to generate image: $e');
    }
  }

  // Removed fallback URL generator (no longer used with OpenAI)

  /// Анализ изображения: принимает байты изображения и возвращает текстовый анализ.
  /// Метод формирует похожий на текстовый запрос к генеративному endpoint'у,
  /// вкладывая изображение в тело запроса в base64 и запрашивая анализ.
  /// Это best-effort: реальный формат запроса зависит от целевого API.
  /// Анализ изображения через Google Cloud Vision API (images:annotate).
  /// Возвращает читабельный текст с метками, свойствами цвета и safe-search.
  Future<String> analyzeImageBytes(Uint8List bytes, {String instruction = ''}) async {
    if (!isConfigured) throw Exception('AI API not configured');

    final visionUrl = Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$apiKey');
    final body = {
      'requests': [
        {
          'image': {
            'content': base64Encode(bytes),
          },
          'features': [
            {'type': 'LABEL_DETECTION', 'maxResults': 10},
            {'type': 'IMAGE_PROPERTIES', 'maxResults': 5},
            {'type': 'SAFE_SEARCH_DETECTION', 'maxResults': 1},
            {'type': 'WEB_DETECTION', 'maxResults': 5}
          ]
        }
      ]
    };

    final resp = await http.post(visionUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body)).timeout(const Duration(seconds: 20));

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // Friendly handling for common permission/disabled errors (403)
      if (resp.statusCode == 403) {
        try {
          final bodyMap = jsonDecode(resp.body);
          final errMsg = bodyMap is Map && bodyMap['error'] != null && bodyMap['error']['message'] != null
              ? bodyMap['error']['message']
              : null;
          // Try to extract an activation URL if present in the body text
          final actMatch = RegExp(r'https:\/\/console\.developers\.google\.com\/[^"]+').firstMatch(resp.body);
          final activationUrl = actMatch?.group(0);
          final friendly = StringBuffer();
          friendly.writeln(errMsg ?? 'Permission denied (403) from Vision API.');
          if (activationUrl != null) {
            friendly.writeln('Enable the API here: $activationUrl');
          } else {
            friendly.writeln('Enable Cloud Vision API for your project in Google Cloud Console.');
          }
          throw Exception('Image analysis API error: ${resp.statusCode} ${friendly.toString()}');
        } catch (_) {
          throw Exception('Image analysis API error: ${resp.statusCode} ${resp.body}');
        }
      }
      throw Exception('Image analysis API error: ${resp.statusCode} ${resp.body}');
    }

    final Map parsed = jsonDecode(resp.body) as Map;
    if (parsed['responses'] == null || parsed['responses'].isEmpty) {
      throw Exception('Empty analysis response: ${resp.body}');
    }

    final r = parsed['responses'][0] as Map;
    final parts = <String>[];

    // Labels
    if (r['labelAnnotations'] != null) {
      final labels = (r['labelAnnotations'] as List).map((e) => e['description']).whereType<String>().toList();
      if (labels.isNotEmpty) parts.add('Метки: ${labels.join(', ')}.');
    }

    // Image properties (colors)
    if (r['imagePropertiesAnnotation'] != null && r['imagePropertiesAnnotation']['dominantColors'] != null) {
      try {
        final cols = r['imagePropertiesAnnotation']['dominantColors']['colors'] as List;
        final top = cols.take(3).map((c) {
          final color = c['color'];
          if (color != null && color['red'] != null) {
            final rr = color['red'];
            final gg = color['green'];
            final bb = color['blue'];
            return '#${(rr as int).toRadixString(16).padLeft(2, '0')}${(gg as int).toRadixString(16).padLeft(2, '0')}${(bb as int).toRadixString(16).padLeft(2, '0')}';
          }
          return null;
        }).whereType<String>().toList();
        if (top.isNotEmpty) parts.add('Доминирующие цвета: ${top.join(', ')}.');
      } catch (_) {}
    }

    // Safe search
    if (r['safeSearchAnnotation'] != null) {
      final ss = r['safeSearchAnnotation'] as Map;
      final safes = <String>[];
      for (final k in ['adult', 'medical', 'racy', 'violence', 'spoof']) {
        if (ss[k] != null) safes.add('$k: ${ss[k]}');
      }
      if (safes.isNotEmpty) parts.add('SafeSearch: ${safes.join(', ')}.');
    }

    // Web detection (best-effort)
    if (r['webDetection'] != null) {
      try {
        final web = r['webDetection'] as Map;
        if (web['bestGuessLabels'] != null) {
          final guesses = (web['bestGuessLabels'] as List).map((e) => e['label']).whereType<String>().toList();
          if (guesses.isNotEmpty) parts.add('Похожие результаты в вебе: ${guesses.join(', ')}.');
        }
      } catch (_) {}
    }

    // Web text fallback
    if (parts.isEmpty) {
      // Try to extract any textual explanation from other fields
      final deep = _deepFindText(r);
      if (deep != null && deep.isNotEmpty) parts.add(deep);
    }

    final result = parts.isNotEmpty ? parts.join(' ') : 'Невозможно извлечь явные признаки; см. полный ответ: ${resp.body}';
    return result;
  }

  /// Скачивает изображение по URL и вызывает analyzeImageBytes.
  Future<String> analyzeImageUrl(String imageUrl, {String instruction = ''}) async {
    final resp = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return analyzeImageBytes(resp.bodyBytes, instruction: instruction);
    }
    throw Exception('Failed to download image for analysis: ${resp.statusCode} ${resp.body}');
  }

  /// Генерация аудио через Google Translate TTS (бесплатно)
  /// Параметры:
  /// - prompt: текст для озвучивания (макс 200 символов за раз)
  /// - voice: язык голоса (ru, en, es, fr, de, ja, ko, zh)
  /// Возвращает байты аудиофайла (MP3)
  Future<AudioResult> generateAudio(String prompt, {String voice = 'ru'}) async {
    // Google Translate TTS имеет лимит в 200 символов
    final text = prompt.length > 200 ? prompt.substring(0, 200) : prompt;
    final encodedText = Uri.encodeComponent(text);
    
    // Google Translate TTS API
    final url = Uri.parse(
      'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=$voice&q=$encodedText'
    );
    
    try {
      final resp = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      });
      
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.bodyBytes.isNotEmpty) {
          return AudioResult(bytes: resp.bodyBytes);
        }
        throw Exception('Empty audio response');
      }
      throw Exception('Audio API error: ${resp.statusCode}');
    } catch (e) {
      throw Exception('Failed to generate audio: $e');
    }
  }
}

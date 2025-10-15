import 'package:flutter_riverpod/legacy.dart';
import 'package:edurise/di/providers.dart';
import 'package:edurise/di/ai_api_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:edurise/features/ai_chat/presentation/utils/pdf_generator.dart';
import 'package:flutter/services.dart';
import 'package:edurise/features/ai_chat/data/services/chat_history_service.dart';
import 'package:edurise/features/ai_chat/data/models/chat_history_model.dart';
import 'package:edurise/features/ai_chat/data/services/moderation_service.dart';
import 'package:path_provider/path_provider.dart';

/// Простые модели для сообщений и состояния чата
class ChatMessage {
  final String text;
  final String? filePath;
  final bool isUser;
  final bool isLoading;
  final bool isError;
  final List<String>? quickOptions; // Варианты для быстрого выбора
  final bool needsTextInput; // Нужен ли текстовый ввод
  final bool isGeneratingPdf; // Генерируется ли PDF файл
  final bool isFlagged; // Помечено модерацией
  final String? flagReason; // Причина пометки
  final List<String>? detectedIssues; // Обнаруженные проблемы

  ChatMessage({
    required this.text,
    this.filePath,
    this.isUser = false,
    this.isLoading = false,
    this.isError = false,
    this.quickOptions,
    this.needsTextInput = false,
    this.isGeneratingPdf = false,
    this.isFlagged = false,
    this.flagReason,
    this.detectedIssues,
  });

  ChatMessage copyWith({
    String? text,
    String? filePath,
    bool? isUser,
    bool? isLoading,
    bool? isError,
    List<String>? quickOptions,
    bool? needsTextInput,
    bool? isGeneratingPdf,
    bool? isFlagged,
    String? flagReason,
    List<String>? detectedIssues,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      filePath: filePath ?? this.filePath,
      isUser: isUser ?? this.isUser,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      quickOptions: quickOptions ?? this.quickOptions,
      needsTextInput: needsTextInput ?? this.needsTextInput,
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
      isFlagged: isFlagged ?? this.isFlagged,
      flagReason: flagReason ?? this.flagReason,
      detectedIssues: detectedIssues ?? this.detectedIssues,
    );
  }
}

class PlanCreationState {
  final String? subject;
  final String? classLevel;
  final String? language;
  final String? topic;
  final int step; // 0=не начато, 1=ждем предмет, 2=ждем класс, 3=ждем язык, 4=ждем тему

  const PlanCreationState({
    this.subject,
    this.classLevel,
    this.language,
    this.step = 0,
    this.topic,
  });

  PlanCreationState copyWith({
    String? subject,
    String? classLevel,
    String? language,
    String? topic,
    int? step,
  }) {
    return PlanCreationState(
      subject: subject ?? this.subject,
      classLevel: classLevel ?? this.classLevel,
      language: language ?? this.language,
      topic: topic ?? this.topic,
      step: step ?? this.step,
    );
  }

  void reset() {}
}

class AiChatState {
  final List<ChatMessage> messages;
  final PlanCreationState planCreation;
  final String? currentChatId; // ID текущего чата
  final bool isImageGenerationMode; // Режим генерации изображения
  final bool isAudioGenerationMode; // Режим генерации аудио

  const AiChatState({
    this.messages = const [],
    this.planCreation = const PlanCreationState(),
    this.currentChatId,
    this.isImageGenerationMode = false,
    this.isAudioGenerationMode = false,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    PlanCreationState? planCreation,
    String? currentChatId,
    bool? isImageGenerationMode,
    bool? isAudioGenerationMode,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      planCreation: planCreation ?? this.planCreation,
      currentChatId: currentChatId ?? this.currentChatId,
      isImageGenerationMode:
          isImageGenerationMode ?? this.isImageGenerationMode,
      isAudioGenerationMode:
          isAudioGenerationMode ?? this.isAudioGenerationMode,
    );
  }

  // PDF generation removed — responses will be returned as plain text messages.
}

/// Провайдер и ViewModel
final aiChatViewModelProvider =
    StateNotifierProvider<AiChatViewModel, AiChatState>((ref) {
  final api = ref.watch(aiApiServiceProvider);
  return AiChatViewModel(api);
});

class AiChatViewModel extends StateNotifier<AiChatState> {
  final AiApiService api;
  final ChatHistoryService _historyService = ChatHistoryService();
  final ModerationService _moderationService = ModerationService();
  Timer? _saveDebounce;

  AiChatViewModel(this.api) : super(const AiChatState());

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  // Загрузить шаблон плана-конспекта
  Future<String> _loadTemplate() async {
    return await rootBundle.loadString('assets/files/example-plan.txt');
  }

  // Построить промпт с использованием шаблона
  String _buildPromptWithTemplate(
      String subject, String classLevel, String topic, String template, String language) {
    final prompt = StringBuffer();
    prompt.writeln('Ты помощник учителя. Твоя задача - создать план-конспект урока СТРОГО по образцу.');
    prompt.writeln('');
    prompt.writeln('ПАРАМЕТРЫ УРОКА:');
    prompt.writeln('Предмет: $subject');
    prompt.writeln('Класс: $classLevel');
    prompt.writeln('Тема: $topic');
    prompt.writeln('Язык: $language');
    prompt.writeln('');
    prompt.writeln('ОБРАЗЕЦ ПЛАНА-КОНСПЕКТА (используй ТОЧНО ТАКУЮ ЖЕ структуру и формат):');
    prompt.writeln('---');
    prompt.writeln(template);
    prompt.writeln('---');
    prompt.writeln('');
    prompt.writeln('ИНСТРУКЦИИ:');
    prompt.writeln('1. Используй ТОЧНО ТАКУЮ ЖЕ структуру как в образце выше');
    prompt.writeln('2. Сохрани ВСЕ разделы, таблицы и их формат (markdown)');
    prompt.writeln('3. ЗАМЕНИ только СОДЕРЖИМОЕ на тему "$topic" для предмета "$subject"');
    prompt.writeln('4. Весь текст должен быть ПОЛНОСТЬЮ на ${language.toLowerCase()} языке');
    prompt.writeln('5. НЕ добавляй никаких объяснений, комментариев или дополнительного текста');
    prompt.writeln('6. Верни ТОЛЬКО готовый план-конспект, начиная с "**Тема:**"');
    prompt.writeln('');
    prompt.writeln('НАЧНИ ОТВЕТ СРАЗУ С ПЛАНА-КОНСПЕКТА:');

    return prompt.toString();
  }

  // Приватный sanitizer для текста
  String _sanitizeText(String input) {
    var s = input;
    // Remove BOM if present
    s = s.replaceAll('\ufeff', '');

    // Collapse quadruple-escaped backslashes to double-escaped (e.g. \\\\ -> \\)
    s = s.replaceAll(r'\\\\', r'\\');
    // Collapse double-escaped backslashes to single-escaped (\\ -> \\)
    s = s.replaceAll(r'\\', r'\\');

    // Replace literal escaped sequences (backslash + n/r/t) with real ones
    s = s.replaceAll(r'\n', '\n');
    s = s.replaceAll(r'\r', '\r');
    s = s.replaceAll(r'\t', '\t');

    // Helper to decode \uXXXX patterns
    String decodeUnicodeEscapes(String str) {
      return str.replaceAllMapped(RegExp(r'\\u([0-9a-fA-F]{4})'), (m) {
        try {
          final code = int.parse(m[1]!, radix: 16);
          return String.fromCharCode(code);
        } catch (_) {
          return m[0]!;
        }
      });
    }

    // First pass
    s = decodeUnicodeEscapes(s);
    // If looks like a JSON-encoded string literal (e.g. '"...\u0430..."'), try jsonDecode
    if (s.trim().startsWith('"') && s.trim().endsWith('"')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is String && decoded != s) {
          s = decoded;
        }
      } catch (_) {}
    }
    // If the result still contains \uXXXX sequences (double-escaped), decode again
    if (RegExp(r'\\u[0-9a-fA-F]{4}').hasMatch(s)) {
      s = decodeUnicodeEscapes(s);
    }

    // Unescape common quoted sequences
    s = s.replaceAll(r'\"', '"');
    s = s.replaceAll(r"\\'", "'");

    // Normalize NBSP and CRLF
    s = s.replaceAll('\u00A0', ' ');
    s = s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Remove other control chars except newline and tab
    s = s.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

    // Normalize repeated blank lines and spaces
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    s = s.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    // Normalize bullets
    s = s.replaceAll(RegExp(r'[\u2022\u2023\u25E6\u2043\u00B7]'), '•');

    // Trim trailing whitespace on lines
    final lines = s.split('\n').map((l) => l.trimRight()).toList();
    s = lines.join('\n');
    return s.trim();
  }

  // PDF helper removed.

  /// Начать процесс создания плана
  Future<void> startPlanCreation() async {
    // Создать новый чат если его еще нет
    if (state.currentChatId == null) {
      await createNewChat();
    }

    state = state.copyWith(
      planCreation: const PlanCreationState(step: 1),
      messages: [
        ...state.messages,
        ChatMessage(
          text: 'Создание плана-конспекта\n\nВыберите предмет:',
          isUser: false,
          quickOptions: [
            'Математика',
            'Русский язык',
            'Кыргыз тили',
            'История',
            'Физика',
            'Биология',
            'Английский язык',
            'География',
          ],
        ),
      ],
    );

    // Сохранить в Firestore
    await _saveCurrentMessages();
  }

  /// Отменить процесс создания плана
  void cancelPlanCreation() {
    state = state.copyWith(
      planCreation: const PlanCreationState(step: 0),
      messages: [
        ...state.messages,
        ChatMessage(text: 'Создание плана отменено.', isUser: false),
      ],
    );
  }

  /// Начать режим генерации изображения
  Future<void> startImageGeneration() async {
    // Создать новый чат если его еще нет
    if (state.currentChatId == null) {
      await createNewChat();
    }

    state = state.copyWith(
      isImageGenerationMode: true,
      messages: [
        ...state.messages,
        ChatMessage(
          text:
              'Режим генерации изображения активирован.\n\nОпишите изображение, которое хотите создать:',
          isUser: false,
        ),
      ],
    );

    // Сохранить в Firestore
    await _saveCurrentMessages();
  }

  Future<void> startAudioGeneration() async {
    // Создать новый чат если его еще нет
    if (state.currentChatId == null) {
      await createNewChat();
    }

    state = state.copyWith(
      isAudioGenerationMode: true,
      messages: [
        ...state.messages,
        ChatMessage(
          text:
              'Режим генерации аудио активирован.\n\nВведите текст для озвучивания:',
          isUser: false,
        ),
      ],
    );

    // Сохранить в Firestore
    await _saveCurrentMessages();
  }

  /// Генерировать изображение и добавить в чат
  Future<void> _generateImageAndAddToChat(String prompt) async {
    // Добавляем placeholder для ответа (loading)
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(text: 'Генерирую изображение...', isLoading: true),
    ]);

    final responseIndex = state.messages.length - 1;

    try {
      // Генерируем изображение
      final res = await api.generateImageBytes(prompt, size: '1024x1024');

      if (res.hasBytes) {
        // Сохраняем изображение во временный файл
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'generated_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(res.bytes!);

        // Обновляем сообщение с путем к файлу
        final msgs = state.messages;
        if (responseIndex < msgs.length) {
          final settled = msgs[responseIndex].copyWith(
            text: 'Изображение сгенерировано',
            filePath: file.path,
            isLoading: false,
          );
          state = state.copyWith(
            messages: [
              ...msgs.sublist(0, responseIndex),
              settled,
            ],
            isImageGenerationMode: false, // Выключаем режим
          );
        }
      } else {
        throw Exception('Не удалось получить изображение');
      }

      // Сохранить в Firestore
      await _saveCurrentMessages();
    } catch (e) {
      final msgs = state.messages;
      state = state.copyWith(
        messages: [
          ...msgs.sublist(0, responseIndex),
          ChatMessage(
              text: 'Ошибка генерации изображения: ${e.toString()}',
              isError: true),
        ],
        isImageGenerationMode: false, // Выключаем режим
      );

      // Сохранить в Firestore
      await _saveCurrentMessages();
    }
  }

  /// Генерировать аудио и добавить в чат
  Future<void> _generateAudioAndAddToChat(String prompt) async {
    // Добавляем placeholder для ответа (loading)
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(text: 'Генерирую аудио...', isLoading: true),
    ]);

    final responseIndex = state.messages.length - 1;

    try {
      // Генерируем аудио (используем русский язык)
      final res = await api.generateAudio(prompt, voice: 'ru');

      // Сохраняем аудио во временный файл
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'generated_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(res.bytes);

      // Обновляем сообщение с путем к файлу
      final msgs = state.messages;
      if (responseIndex < msgs.length) {
        final settled = msgs[responseIndex].copyWith(
          text: 'Аудио сгенерировано',
          filePath: file.path,
          isLoading: false,
        );
        state = state.copyWith(
          messages: [
            ...msgs.sublist(0, responseIndex),
            settled,
          ],
          isAudioGenerationMode: false, // Выключаем режим
        );
      }

      // Сохранить в Firestore
      await _saveCurrentMessages();
    } catch (e) {
      final msgs = state.messages;
      state = state.copyWith(
        messages: [
          ...msgs.sublist(0, responseIndex),
          ChatMessage(
              text: 'Ошибка генерации аудио: ${e.toString()}',
              isError: true),
        ],
        isAudioGenerationMode: false, // Выключаем режим
      );

      // Сохранить в Firestore
      await _saveCurrentMessages();
    }
  }

  /// Обработать сообщение пользователя в процессе создания плана
  Future<void> _handlePlanCreationStep(String userInput) async {
    final step = state.planCreation.step;

    if (step == 1) {
      // Обработка выбора предмета
      state = state.copyWith(
        planCreation: state.planCreation.copyWith(subject: userInput, step: 2),
        messages: [
          ...state.messages,
          ChatMessage(
            text: 'Выбран предмет: $userInput\n\nВыберите класс:',
            isUser: false,
            quickOptions: List.generate(11, (i) => '${i + 1} класс'),
          ),
        ],
      );
    } else if (step == 2) {
      // Обработка выбора класса
      state = state.copyWith(
        planCreation:
            state.planCreation.copyWith(classLevel: userInput, step: 3),
        messages: [
          ...state.messages,
          ChatMessage(
            text: 'Выбран класс: $userInput\n\nВыберите язык плана:',
            isUser: false,
            quickOptions: [
              'Русский',
              'Кыргызский',
              'Английский',
              'Казахский',
              'Узбекский',
            ],
          ),
        ],
      );
    } else if (step == 3) {
      // Обработка выбора языка
      state = state.copyWith(
        planCreation:
            state.planCreation.copyWith(language: userInput, step: 4),
        messages: [
          ...state.messages,
          ChatMessage(
            text: 'Выбран язык: $userInput\n\nВведите тему урока:',
            isUser: false,
            needsTextInput: true,
          ),
        ],
      );
    } else if (step == 4) {
      // Получили тему - генерируем план
      final topic = userInput.trim();
      if (topic.isNotEmpty) {
        state = state.copyWith(
          planCreation: state.planCreation.copyWith(topic: topic, step: 0),
          messages: [
            ...state.messages,
            ChatMessage(
                text: 'Тема: $topic\n\nГенерирую план-конспект...',
                isLoading: true),
          ],
        );

        final subject = state.planCreation.subject!;
        final classLevel = state.planCreation.classLevel!;
        final language = state.planCreation.language ?? 'Русский';

        // Загружаем шаблон
        try {
          final template = await _loadTemplate();
          final prompt =
              _buildPromptWithTemplate(subject, classLevel, topic, template, language);
          await generatePlanPdfAndAddToChat(
              prompt, 'План_${subject}_${classLevel}_$topic');
        } catch (e) {
          // Если не удалось загрузить шаблон, используем простой промпт
          final prompt =
              'Создай подробный план-конспект урока по предмету "$subject" для "$classLevel" на тему "$topic". ВАЖНО: весь план должен быть написан на ${language.toLowerCase()} языке.';
          await generatePlanPdfAndAddToChat(
              prompt, 'План_${subject}_${classLevel}_$topic');
        }

        // Сбросить состояние
        state = state.copyWith(planCreation: const PlanCreationState(step: 0));
      } else {
        state = state.copyWith(messages: [
          ...state.messages,
          ChatMessage(
              text:
                  'Тема не может быть пустой. Пожалуйста, введите тему урока.',
              isUser: false,
              needsTextInput: true),
        ]);
      }
    }
  }

  /// Создать новый чат (или использовать существующий пустой)
  Future<void> createNewChat() async {
    // Проверяем, есть ли уже пустой чат
    if (state.currentChatId != null && state.messages.isEmpty) {
      // Уже есть пустой чат, ничего не делаем
      return;
    }

    // Сначала обновляем UI (быстро)
    state = state.copyWith(
      currentChatId: null, // Временно null, чтобы показать чистый чат
      messages: [],
      planCreation:
          const PlanCreationState(step: 0), // Сбросить состояние создания плана
    );

    // Затем создаем чат в Firestore (асинхронно)
    final chatId = await _historyService.createChat(title: 'Новый чат');
    state = state.copyWith(currentChatId: chatId);
  }

  /// Загрузить чат по ID
  Future<void> loadChat(String chatId) async {
    final chat = await _historyService.getChat(chatId);
    if (chat != null) {
      state = state.copyWith(
        currentChatId: chatId,
        messages: chat.messages
            .map((m) => ChatMessage(
                  text: m.text,
                  filePath: m.filePath,
                  isUser: m.isUser,
                  isLoading: m.isLoading,
                  isError: m.isError,
                  quickOptions: m.quickOptions,
                  needsTextInput: m.needsTextInput,
                ))
            .toList(),
      );
    }
  }

  /// Сохранить текущие сообщения с debounce (оптимизация производительности)
  Future<void> _saveCurrentMessages({bool immediate = false}) async {
    if (state.currentChatId == null) return;

    if (immediate) {
      // Немедленное сохранение
      await _performSave();
    } else {
      // Отложенное сохранение (debounce)
      _saveDebounce?.cancel();
      _saveDebounce = Timer(const Duration(milliseconds: 500), () {
        _performSave();
      });
    }
  }

  Future<void> _performSave() async {
    if (state.currentChatId == null) return;

    final messages = state.messages
        .map((m) => ChatMessageModel(
              text: m.text,
              filePath: m.filePath,
              isUser: m.isUser,
              isLoading: m.isLoading,
              isError: m.isError,
              quickOptions: m.quickOptions,
              needsTextInput: m.needsTextInput,
            ))
        .toList();

    await _historyService.saveMessages(
      chatId: state.currentChatId!,
      messages: messages,
    );

    // Обновить заголовок чата на основе ПЕРВОГО сообщения пользователя
    // Проверяем, что текущий заголовок - это "Новый чат" (значит еще не обновлялся)
    final currentChat = await _historyService.getChat(state.currentChatId!);
    if (currentChat != null && currentChat.title == 'Новый чат') {
      // Находим первое сообщение пользователя
      final firstUserMessage = messages.firstWhere(
        (m) => m.isUser && m.text.isNotEmpty,
        orElse: () => ChatMessageModel(text: ''),
      );

      if (firstUserMessage.text.isNotEmpty) {
        final title = firstUserMessage.text.length > 50
            ? '${firstUserMessage.text.substring(0, 50)}...'
            : firstUserMessage.text;
        await _historyService.updateChatTitle(state.currentChatId!, title);
      }
    }
  }

  /// Анализ намерения пользователя и извлечение параметров
  Future<Map<String, dynamic>?> _analyzeIntent(String text) async {
    final lower = text.toLowerCase();
    
    // Проверка на план-конспект
    if (lower.contains('план') && (lower.contains('конспект') || lower.contains('урок'))) {
      return {'intent': 'create_plan'};
    }
    
    // Проверка на генерацию изображения
    if ((lower.contains('создай') || lower.contains('сгенерируй') || lower.contains('нарисуй')) 
        && (lower.contains('картинк') || lower.contains('изображени') || lower.contains('рисунок'))) {
      
      // Извлекаем описание изображения
      String description = text;
      
      // Убираем триггерные слова
      description = description.replaceAll(RegExp(r'создай\s+(картинк|изображени|рисунок)[уа]?\s*', caseSensitive: false), '');
      description = description.replaceAll(RegExp(r'сгенерируй\s+(картинк|изображени|рисунок)[уа]?\s*', caseSensitive: false), '');
      description = description.replaceAll(RegExp(r'нарисуй\s*', caseSensitive: false), '');
      description = description.trim();
      
      if (description.isNotEmpty) {
        return {'intent': 'generate_image', 'description': description};
      }
    }
    
    // Проверка на генерацию аудио
    if ((lower.contains('озвучь') || lower.contains('создай аудио') || lower.contains('голосом'))
        && !lower.contains('картинк') && !lower.contains('изображени')) {
      
      // Извлекаем текст для озвучивания
      String audioText = text;
      audioText = audioText.replaceAll(RegExp(r'озвучь\s*', caseSensitive: false), '');
      audioText = audioText.replaceAll(RegExp(r'создай\s+аудио\s*', caseSensitive: false), '');
      audioText = audioText.replaceAll(RegExp(r'голосом\s*', caseSensitive: false), '');
      audioText = audioText.trim();
      
      if (audioText.isNotEmpty) {
        return {'intent': 'generate_audio', 'text': audioText};
      }
    }
    
    return null;
  }

  /// Отправить сообщение пользователя и начать получать стрим ответа
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // МОДЕРАЦИЯ: Проверяем сообщение перед отправкой
    final moderationResult = await _moderationService.moderateMessage(trimmed);
    
    // Если сообщение заблокировано - показываем ошибку
    if (!moderationResult.isAllowed) {
      state = state.copyWith(messages: [
        ...state.messages,
        ChatMessage(
          text: trimmed,
          isUser: true,
          isFlagged: true,
          flagReason: moderationResult.reason,
          detectedIssues: moderationResult.detectedIssues,
        ),
        ChatMessage(
          text: _moderationService.getUserFeedbackMessage(moderationResult),
          isUser: false,
          isError: true,
        ),
      ]);
      return;
    }

    // Создать новый чат если его еще нет
    if (state.currentChatId == null) {
      await createNewChat();
    }

    // Добавляем сообщение пользователя (с пометкой если помечено модерацией)
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(
        text: trimmed,
        isUser: true,
        isFlagged: moderationResult.isFlagged,
        flagReason: moderationResult.reason,
        detectedIssues: moderationResult.detectedIssues,
      ),
    ]);

    // Помечаем чат как требующий модерации если сообщение помечено
    if (moderationResult.isFlagged && state.currentChatId != null) {
      await _historyService.flagChat(
        chatId: state.currentChatId!,
        reason: moderationResult.reason ?? 'Автоматическая пометка',
      );
    }

    // Сохранить в Firestore
    await _saveCurrentMessages();

    // Анализ намерения пользователя (только если не в специальном режиме)
    if (state.planCreation.step == 0 && 
        !state.isImageGenerationMode && 
        !state.isAudioGenerationMode) {
      final intentData = await _analyzeIntent(trimmed);
      
      if (intentData != null) {
        final intent = intentData['intent'];
        
        if (intent == 'create_plan') {
          await startPlanCreation();
          return;
        } else if (intent == 'generate_image') {
          final description = intentData['description'] as String;
          await _generateImageAndAddToChat(description);
          await _saveCurrentMessages();
          return;
        } else if (intent == 'generate_audio') {
          final audioText = intentData['text'] as String;
          await _generateAudioAndAddToChat(audioText);
          await _saveCurrentMessages();
          return;
        }
      }
    }

    // Если активен режим генерации изображения - генерируем изображение
    if (state.isImageGenerationMode) {
      await _generateImageAndAddToChat(trimmed);
      await _saveCurrentMessages(); // Сохранить после обработки
      return;
    }

    // Если активен режим генерации аудио - генерируем аудио
    if (state.isAudioGenerationMode) {
      await _generateAudioAndAddToChat(trimmed);
      await _saveCurrentMessages(); // Сохранить после обработки
      return;
    }

    // Если идет процесс создания плана - обрабатываем его
    if (state.planCreation.step > 0) {
      await _handlePlanCreationStep(trimmed);
      await _saveCurrentMessages(); // Сохранить после обработки
      return;
    }

    // Добавляем placeholder для ответа бота
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(text: '', isLoading: true),
    ]);

    final responseIndex = state.messages.length - 1;

    if (!api.isConfigured) {
      state = state.copyWith(messages: [
        ...state.messages.sublist(0, responseIndex),
        ChatMessage(text: 'AI API не настроен', isError: true),
      ]);
      return;
    }

    try {
      // Читаем поток чанков из сервиса
      await for (final chunk in api.generateStream(trimmed)) {
        if (chunk.isEmpty) continue;
        final msgs = state.messages;
        if (responseIndex >= msgs.length) break;
        final updated = msgs[responseIndex].copyWith(
          text: msgs[responseIndex].text + chunk,
          isLoading: true,
        );
        state = state.copyWith(messages: [
          ...msgs.sublist(0, responseIndex),
          updated,
        ]);
      }

      // По завершении помечаем сообщение как завершённое (не loading)
      final finalMsgs = state.messages;
      if (responseIndex < finalMsgs.length) {
        final settled = finalMsgs[responseIndex].copyWith(isLoading: false);
        state = state.copyWith(messages: [
          ...finalMsgs.sublist(0, responseIndex),
          settled,
        ]);
      }

      // Сохранить в Firestore
      await _saveCurrentMessages();
    } catch (e) {
      // В случае ошибки показываем сообщение об ошибке
      final msgs = state.messages;
      state = state.copyWith(messages: [
        ...msgs.sublist(0, responseIndex),
        ChatMessage(text: 'Ошибка: ${e.toString()}', isError: true),
      ]);

      // Сохранить в Firestore
      await _saveCurrentMessages();
    }
  }

  void clear() {
    state = const AiChatState();
  }

  /// Генерация изображения по текстовому промпту.
  /// Использует бесплатный API pollinations.ai (не требует API ключ)
  /// Возвращает `ImageResult` (bytes или url) или null в случае ошибки.
  Future<ImageResult?> generateImage(String prompt,
      {String size = '1024x1024'}) async {
    try {
      final res = await api.generateImageBytes(prompt, size: size);
      return res;
    } catch (e) {
      return null;
    }
  }

  /// Отправить байты изображения на анализ. Добавляет в чат запись от пользователя
  /// с пометкой что был загружен файл изображения, затем создаёт placeholder и
  /// заменяет его на текстовый анализ или сообщение об ошибке.
  Future<void> sendImageForAnalysis(Uint8List bytes,
      {String instruction = 'Опишите изображение:'}) async {
    // Добавляем сообщение-пометку от пользователя
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(text: '[Изображение отправлено на анализ]', isUser: true),
    ]);

    // Добавляем placeholder для ответа
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(text: '', isLoading: true),
    ]);

    final responseIndex = state.messages.length - 1;

    if (!api.isConfigured) {
      state = state.copyWith(messages: [
        ...state.messages.sublist(0, responseIndex),
        ChatMessage(text: 'AI API не настроен', isError: true),
      ]);
      return;
    }

    try {
      final analysis =
          await api.analyzeImageBytes(bytes, instruction: instruction);
      final msgs = state.messages;
      if (responseIndex < msgs.length) {
        final settled =
            msgs[responseIndex].copyWith(text: analysis, isLoading: false);
        state = state.copyWith(messages: [
          ...msgs.sublist(0, responseIndex),
          settled,
        ]);
      }
    } catch (e) {
      final msgs = state.messages;
      state = state.copyWith(messages: [
        ...msgs.sublist(0, responseIndex),
        ChatMessage(
            text: 'Ошибка анализа изображения: ${e.toString()}', isError: true),
      ]);
    }
  }

  /// Отправить URL изображения на анализ (скачивает изображение и анализирует).
  Future<void> sendImageUrlForAnalysis(String imageUrl,
      {String instruction = 'Опишите изображение:'}) async {
    // Добавляем сообщение-пометку от пользователя
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(
          text: '[Ссылка на изображение отправлена на анализ] $imageUrl',
          isUser: true),
    ]);

    // Добавляем placeholder для ответа
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(text: '', isLoading: true),
    ]);

    final responseIndex = state.messages.length - 1;

    if (!api.isConfigured) {
      state = state.copyWith(messages: [
        ...state.messages.sublist(0, responseIndex),
        ChatMessage(text: 'AI API не настроен', isError: true),
      ]);
      return;
    }

    try {
      final analysis =
          await api.analyzeImageUrl(imageUrl, instruction: instruction);
      final msgs = state.messages;
      if (responseIndex < msgs.length) {
        final settled =
            msgs[responseIndex].copyWith(text: analysis, isLoading: false);
        state = state.copyWith(messages: [
          ...msgs.sublist(0, responseIndex),
          settled,
        ]);
      }
    } catch (e) {
      final msgs = state.messages;
      state = state.copyWith(messages: [
        ...msgs.sublist(0, responseIndex),
        ChatMessage(
            text: 'Ошибка анализа изображения: ${e.toString()}', isError: true),
      ]);
    }
  }

  /// Генерирует текст (не стрим) по промпту и добавляет в чат как обычный текст.
  /// Генерирует план-конспект и сразу создает PDF
  Future<void> generatePlanPdfAndAddToChat(
      String prompt, String titleForFile) async {
    // Добавляем placeholder для ответа (loading)
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(text: '', isLoading: true, isGeneratingPdf: true),
    ]);

    final responseIndex = state.messages.length - 1;

    if (!api.isConfigured) {
      state = state.copyWith(messages: [
        ...state.messages.sublist(0, responseIndex),
        ChatMessage(text: 'AI API не настроен', isError: true),
      ]);
      return;
    }

    try {
      // Запрашиваем итоговый текст одним вызовом (не стрим)
      final generated = await api.generate(prompt);
      final cleaned = _sanitizeText(generated);

      // 1) Показываем в чате сгенерированный план в виде markdown-сообщения ассистента
      final msgsAfterGen = state.messages;
      if (responseIndex < msgsAfterGen.length) {
        final markdownMessage = msgsAfterGen[responseIndex].copyWith(
          text: cleaned,
          isLoading: false,
          isGeneratingPdf: false,
          isUser: false,
        );
        state = state.copyWith(messages: [
          ...msgsAfterGen.sublist(0, responseIndex),
          markdownMessage,
          ...msgsAfterGen.sublist(responseIndex + 1),
        ]);
      }

      // 2) Генерируем PDF из того же текста и добавляем отдельным сообщением
      var safeName = titleForFile.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      safeName = safeName.replaceAll(RegExp(r'\s+'), '_');
      if (safeName.isEmpty) {
        safeName = 'plan_${DateTime.now().millisecondsSinceEpoch}';
      }

      final result = await PdfGenerator.generatePlanPdf(
        title: safeName,
        content: cleaned,
        fileName: '$safeName.pdf',
        aiGenerate: (prompt) => api.generate(prompt),
      );

      state = state.copyWith(messages: [
        ...state.messages,
        ChatMessage(
          text: result.generatedTitle ?? '$safeName.pdf',
          filePath: result.path,
          isUser: false,
        ),
      ]);
    } catch (e) {
      final msgs = state.messages;
      state = state.copyWith(messages: [
        ...msgs.sublist(0, responseIndex),
        ChatMessage(
            text: 'Ошибка при создании плана: ${e.toString()}', isError: true),
      ]);
    }
  }

  /// Создает PDF из текста и добавляет как новое сообщение в чат
  Future<void> createPdfFromText(String text, {String? title}) async {
    // Добавляем placeholder для ответа (loading)
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(text: '📄 Создаю PDF...', isLoading: true),
    ]);

    final responseIndex = state.messages.length - 1;

    try {
      // Подготовим безопасное имя файла
      var safeName = title ?? 'Документ_${DateTime.now().millisecondsSinceEpoch}';
      safeName = safeName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      safeName = safeName.replaceAll(RegExp(r'\s+'), '_');
      
      // Генерируем PDF из текста
      final result = await PdfGenerator.generatePlanPdf(
        title: safeName,
        content: text,
        fileName: '$safeName.pdf',
        aiGenerate: (prompt) => api.generate(prompt),
      );

      // Заменяем placeholder на сообщение с PDF
      final msgs = state.messages;
      if (responseIndex < msgs.length) {
        final settled = msgs[responseIndex].copyWith(
          text: result.generatedTitle,
          filePath: result.path,
          isLoading: false,
        );
        state = state.copyWith(messages: [
          ...msgs.sublist(0, responseIndex),
          settled,
        ]);
      }

      // Сохранить в Firestore
      await _saveCurrentMessages();
    } catch (e) {
      final msgs = state.messages;
      state = state.copyWith(messages: [
        ...msgs.sublist(0, responseIndex),
        ChatMessage(
            text: 'Ошибка при создании PDF: ${e.toString()}', isError: true),
      ]);
    }
  }

  /// Конвертирует сообщение с индексом [messageIndex] в PDF и прикрепляет путь к сообщению.
  Future<void> convertMessageToPdf(int messageIndex, {String? title}) async {
    if (messageIndex < 0 || messageIndex >= state.messages.length) return;
    final msg = state.messages[messageIndex];
    if (msg.isUser || msg.isLoading || msg.text.trim().isEmpty) return;

    // Пометим сообщение как loading
    final msgsBefore = state.messages;
    final updating = msgsBefore[messageIndex].copyWith(isLoading: true);
    state = state.copyWith(messages: [
      ...msgsBefore.sublist(0, messageIndex),
      updating,
      ...msgsBefore.sublist(messageIndex + 1),
    ]);

    try {
      final content = msg.text;
      final result = await PdfGenerator.generatePlanPdf(
        title: title ?? 'План',
        content: content,
        author: null,
        fileName: null,
        aiGenerate: (prompt) => api.generate(prompt),
      );

      // Обновим сообщение, добавив путь к файлу
      var updated = state.messages[messageIndex]
          .copyWith(filePath: result.path, isLoading: false);

      // Если встроенный шрифт не найден, добавим заметку к тексту, чтобы пользователь понял проблему
      if (!result.fontFound) {
        final note =
            '\n\n[Примечание: встроенный шрифт для кириллицы не найден. PDF может отображать некорректные русские символы. Добавьте шрифт Noto Sans в assets/fonts/ и обновите pubspec.yaml. Для примера: assets/fonts/NotoSans-Regular.ttf]';
        updated = updated.copyWith(text: updated.text + note);
      }

      final msgsFinal = state.messages;
      msgsFinal[messageIndex] = updated;
      state = state.copyWith(messages: [...msgsFinal]);
      print('[ai_chat] PDF saved: ${result.path}');
    } catch (e) {
      // В случае ошибки — пометим как ошибка и вернём текст
      final msgs = state.messages;
      if (messageIndex < msgs.length) {
        final err = msgs[messageIndex].copyWith(
            text: 'Ошибка при создании PDF: ${e.toString()}',
            isError: true,
            isLoading: false);
        state = state.copyWith(messages: [
          ...msgs.sublist(0, messageIndex),
          err,
        ]);
      }
    }
  }
}

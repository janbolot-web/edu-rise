class ModerationResult {
  final bool isAllowed;
  final bool isFlagged;
  final String? reason;
  final List<String> detectedIssues;

  ModerationResult({
    required this.isAllowed,
    this.isFlagged = false,
    this.reason,
    this.detectedIssues = const [],
  });

  factory ModerationResult.allowed() {
    return ModerationResult(isAllowed: true);
  }

  factory ModerationResult.flagged(String reason, List<String> issues) {
    return ModerationResult(
      isAllowed: true,
      isFlagged: true,
      reason: reason,
      detectedIssues: issues,
    );
  }

  factory ModerationResult.blocked(String reason, List<String> issues) {
    return ModerationResult(
      isAllowed: false,
      isFlagged: true,
      reason: reason,
      detectedIssues: issues,
    );
  }
}

class ModerationService {
  // Список запрещенных слов/фраз
  static final List<String> _prohibitedWords = [
    // Оскорбления
    'дурак', 'идиот', 'тупой', 'долбоёб', 'мудак', 'придурок',
    // Мат (примеры)
    'блять', 'сука', 'хуй', 'пизд', 'ебать', 'ебл', 'ёб',
    // Угрозы
    'убью', 'убить', 'смерть', 'убийство', 'покончу',
    // Дискриминация
    'фашист', 'нацист',
  ];

  // Список слов для предупреждения (не блокируют, но помечают)
  static final List<String> _warningWords = [
    'дурочка', 'глупый', 'тупица', 'болван',
    'ненавижу', 'ненависть',
    'грустно', 'одиноко', 'депрессия',
  ];

  // Паттерны для обнаружения личной информации
  static final List<RegExp> _personalInfoPatterns = [
    // Номера телефонов
    RegExp(r'\+?\d{1,3}[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{2}[-.\s]?\d{2}'),
    // Email адреса
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
    // Номера карт (упрощенный паттерн)
    RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
    // Адреса (упрощенный паттерн)
    RegExp(r'\b(?:улица|ул\.|проспект|пр\.|переулок|пер\.)\s+[А-Яа-яЁё\s]+,?\s*\d+'),
  ];

  // Паттерны для обнаружения спама
  static final List<RegExp> _spamPatterns = [
    RegExp(r'(?:кликни|нажми|перейди)\s+(?:по\s+)?(?:ссылке|здесь)', caseSensitive: false),
    RegExp(r'(?:заработок|заработать)\s+(?:в\s+интернете|онлайн|дома)', caseSensitive: false),
    RegExp(r'(?:выиграл|выиграть|приз|подарок)\s+(?:бесплатно|даром)', caseSensitive: false),
  ];

  /// Проверяет текст сообщения на соответствие правилам модерации
  Future<ModerationResult> moderateMessage(String text) async {
    final issues = <String>[];
    
    // 1. Проверка на запрещенные слова
    final prohibitedFound = _checkProhibitedWords(text.toLowerCase());
    if (prohibitedFound.isNotEmpty) {
      issues.add('Обнаружены запрещенные слова: ${prohibitedFound.join(", ")}');
      return ModerationResult.blocked(
        'Сообщение содержит недопустимые выражения',
        issues,
      );
    }

    // 2. Проверка на слова-предупреждения
    final warningFound = _checkWarningWords(text.toLowerCase());
    if (warningFound.isNotEmpty) {
      issues.add('Обнаружены нежелательные слова: ${warningFound.join(", ")}');
    }

    // 3. Проверка на личную информацию
    final personalInfoFound = _checkPersonalInfo(text);
    if (personalInfoFound) {
      issues.add('Возможно содержит личную информацию (телефон, email, адрес)');
    }

    // 4. Проверка на спам
    final spamFound = _checkSpam(text);
    if (spamFound) {
      issues.add('Возможно содержит спам или рекламу');
    }

    // 5. Проверка на чрезмерное использование CAPS
    final excessiveCaps = _checkExcessiveCaps(text);
    if (excessiveCaps) {
      issues.add('Чрезмерное использование заглавных букв');
    }

    // 6. Проверка на повторяющиеся символы
    final repeatedChars = _checkRepeatedCharacters(text);
    if (repeatedChars) {
      issues.add('Чрезмерное повторение символов');
    }

    // Если есть проблемы - помечаем сообщение
    if (issues.isNotEmpty) {
      return ModerationResult.flagged(
        'Сообщение помечено для проверки',
        issues,
      );
    }

    return ModerationResult.allowed();
  }

  /// Проверяет изображение (заглушка для будущей реализации)
  Future<ModerationResult> moderateImage(String imagePath) async {
    // TODO: Интеграция с API для модерации изображений (например, Google Vision API)
    // Пока просто разрешаем все изображения
    return ModerationResult.allowed();
  }

  /// Проверяет весь чат на наличие проблем
  Future<ModerationResult> moderateChat(List<String> messages) async {
    final allIssues = <String>[];
    var hasBlockedContent = false;

    for (var i = 0; i < messages.length; i++) {
      final result = await moderateMessage(messages[i]);
      if (!result.isAllowed) {
        hasBlockedContent = true;
        allIssues.add('Сообщение ${i + 1}: ${result.reason}');
      } else if (result.isFlagged) {
        allIssues.addAll(result.detectedIssues.map((issue) => 'Сообщение ${i + 1}: $issue'));
      }
    }

    if (hasBlockedContent) {
      return ModerationResult.blocked('Чат содержит недопустимый контент', allIssues);
    } else if (allIssues.isNotEmpty) {
      return ModerationResult.flagged('Чат требует проверки', allIssues);
    }

    return ModerationResult.allowed();
  }

  // Вспомогательные методы

  List<String> _checkProhibitedWords(String text) {
    final found = <String>[];
    for (final word in _prohibitedWords) {
      if (text.contains(word)) {
        found.add(word);
      }
    }
    return found;
  }

  List<String> _checkWarningWords(String text) {
    final found = <String>[];
    for (final word in _warningWords) {
      if (text.contains(word)) {
        found.add(word);
      }
    }
    return found;
  }

  bool _checkPersonalInfo(String text) {
    for (final pattern in _personalInfoPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  bool _checkSpam(String text) {
    for (final pattern in _spamPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  bool _checkExcessiveCaps(String text) {
    if (text.length < 10) return false;
    
    final letters = text.replaceAll(RegExp(r'[^А-Яа-яA-Za-z]'), '');
    if (letters.isEmpty) return false;
    
    final upperCount = text.replaceAll(RegExp(r'[^А-ЯA-Z]'), '').length;
    final ratio = upperCount / letters.length;
    
    return ratio > 0.7; // Если более 70% букв заглавные
  }

  bool _checkRepeatedCharacters(String text) {
    // Проверяем на более 4 повторяющихся символов подряд
    final pattern = RegExp(r'(.)\1{4,}');
    return pattern.hasMatch(text);
  }

  /// Получает рекомендацию по модерации на основе результата
  String getModerationRecommendation(ModerationResult result) {
    if (!result.isAllowed) {
      return 'Заблокировать сообщение и предупредить пользователя';
    } else if (result.isFlagged) {
      return 'Пометить для ручной проверки модератором';
    } else {
      return 'Разрешить без ограничений';
    }
  }

  /// Генерирует сообщение для пользователя о модерации
  String getUserFeedbackMessage(ModerationResult result) {
    if (!result.isAllowed) {
      return 'Ваше сообщение не может быть отправлено, так как нарушает правила общения. '
          'Пожалуйста, перефразируйте свое сообщение без использования недопустимых выражений.';
    } else if (result.isFlagged) {
      return 'Обратите внимание: ваше сообщение будет проверено модератором.';
    } else {
      return '';
    }
  }
}

# AI Chat Moderation System

## Обзор

Система модерации для AI чата обеспечивает автоматическую проверку сообщений пользователей на предмет нежелательного контента.

## Компоненты системы

### 1. ModerationService
**Файл:** `lib/features/ai_chat/data/services/moderation_service.dart`

Основной сервис модерации, который проверяет текст сообщений на:
- Запрещенные слова (оскорбления, мат, угрозы)
- Нежелательные слова (предупреждения)
- Личную информацию (телефоны, email, адреса, номера карт)
- Спам и рекламу
- Чрезмерное использование заглавных букв
- Повторяющиеся символы

#### Методы:

```dart
// Модерация сообщения
Future<ModerationResult> moderateMessage(String text)

// Модерация изображения (заглушка для будущей реализации)
Future<ModerationResult> moderateImage(String imagePath)

// Модерация всего чата
Future<ModerationResult> moderateChat(List<String> messages)
```

#### Результат модерации:

```dart
class ModerationResult {
  bool isAllowed;      // Разрешено ли сообщение
  bool isFlagged;      // Помечено для проверки
  String? reason;      // Причина блокировки/пометки
  List<String> detectedIssues;  // Обнаруженные проблемы
}
```

### 2. ChatHistoryService (расширенный)
**Файл:** `lib/features/ai_chat/data/services/chat_history_service.dart`

Добавлены методы для работы с модерацией:

```dart
// Модерировать сообщение
Future<ModerationResult> moderateMessage(String text)

// Обновить статус модерации чата
Future<void> updateChatModerationStatus({
  required String chatId,
  required ModerationStatus status,
  String? comment,
  String? moderatedBy,
})

// Пометить чат
Future<void> flagChat({required String chatId, required String reason})

// Одобрить чат
Future<void> approveChat({required String chatId, required String moderatorId})

// Отклонить чат
Future<void> rejectChat({
  required String chatId,
  required String moderatorId,
  required String reason,
})

// Получить чаты для модерации
Stream<List<ChatHistoryModel>> getChatsForModeration({ModerationStatus? status})

// Получить количество чатов, требующих модерации
Future<int> getPendingModerationCount()
Future<int> getFlaggedChatsCount()
```

### 3. Модели данных

#### ChatHistoryModel
Добавлены поля модерации:
```dart
ModerationStatus moderationStatus;  // pending, approved, rejected, flagged
String? moderationComment;          // Комментарий модератора
String? moderatedBy;                // ID модератора
DateTime? moderatedAt;              // Время модерации
```

#### ChatMessageModel
Добавлены поля для помеченных сообщений:
```dart
bool isFlagged;                     // Помечено модерацией
String? flagReason;                 // Причина пометки
List<String>? detectedIssues;       // Обнаруженные проблемы
```

### 4. Интеграция в AiChatViewModel

При отправке сообщения (`sendMessage`):
1. Сообщение проверяется сервисом модерации
2. Если заблокировано - показывается ошибка пользователю
3. Если помечено - сообщение отправляется, но чат помечается для проверки
4. Если разрешено - обрабатывается как обычно

## Статусы модерации

```dart
enum ModerationStatus {
  pending,    // Ожидает модерации
  approved,   // Одобрено
  rejected,   // Отклонено
  flagged,    // Помечено для проверки
}
```

## Настройка фильтров

### Добавление запрещенных слов

В файле `moderation_service.dart` измените список `_prohibitedWords`:

```dart
static final List<String> _prohibitedWords = [
  'слово1', 'слово2', ...
];
```

### Добавление слов-предупреждений

```dart
static final List<String> _warningWords = [
  'слово1', 'слово2', ...
];
```

### Настройка паттернов

Для обнаружения личной информации или спама добавьте регулярные выражения:

```dart
static final List<RegExp> _personalInfoPatterns = [
  RegExp(r'ваш_паттерн'),
];
```

## Сообщения для пользователей

Система автоматически генерирует понятные сообщения:

**При блокировке:**
> "Ваше сообщение не может быть отправлено, так как нарушает правила общения. Пожалуйста, перефразируйте свое сообщение без использования недопустимых выражений."

**При пометке:**
> "Обратите внимание: ваше сообщение будет проверено модератором."

## Панель модератора (будущая функция)

Для создания панели модератора используйте методы:
- `getChatsForModeration()` - получить список чатов
- `getPendingModerationCount()` - количество ожидающих
- `getFlaggedChatsCount()` - количество помеченных
- `approveChat()` - одобрить
- `rejectChat()` - отклонить

## Firestore индексы

Для работы запросов модерации добавьте в `firestore.indexes.json`:

```json
{
  "collectionGroup": "chats",
  "queryScope": "COLLECTION_GROUP",
  "fields": [
    {"fieldPath": "moderationStatus", "order": "ASCENDING"},
    {"fieldPath": "updatedAt", "order": "DESCENDING"}
  ]
}
```

## Будущие улучшения

1. **Модерация изображений**: Интеграция с Google Cloud Vision API или аналогами
2. **AI-модерация**: Использование ML моделей для более точного определения
3. **Контекстный анализ**: Анализ контекста разговора, а не только отдельных слов
4. **Пользовательские настройки**: Разные уровни строгости модерации
5. **Апелляции**: Система обжалования блокировок
6. **Аналитика**: Статистика по модерации

## Пример использования

```dart
// В коде приложения
final moderationService = ModerationService();

// Проверить сообщение
final result = await moderationService.moderateMessage(userMessage);

if (!result.isAllowed) {
  // Показать ошибку
  showError(result.reason);
} else if (result.isFlagged) {
  // Предупредить пользователя
  showWarning("Сообщение будет проверено");
  // Отправить сообщение
  sendMessage(userMessage);
}
```

## Безопасность

- Модерация работает на клиенте для мгновенной обратной связи
- Финальная проверка может выполняться на сервере
- Firestore rules должны ограничивать изменение статуса модерации только для модераторов
- Логи модерации сохраняются для аудита

## Тестирование

Создайте тесты для проверки:
1. Блокировки запрещенных слов
2. Обнаружения личной информации
3. Обнаружения спама
4. Правильной работы статусов
5. Сохранения и загрузки помеченных сообщений

# Tests Feature - Образовательная платформа

Комплексная система тестирования для образовательной платформы EduRise.

## 📋 Структура

```
tests/
├── domain/
│   ├── models/
│   │   ├── question.dart       # Модель вопроса
│   │   ├── test.dart           # Модель теста
│   │   ├── test_attempt.dart   # Модель попытки
│   │   └── user_stats.dart     # Статистика пользователя
│   └── repositories/
├── data/
│   └── repositories/
│       └── test_repository.dart # Репозиторий для работы с Firestore
└── presentation/
    ├── pages/
    │   ├── tests_page.dart           # Каталог тестов
    │   ├── test_details_page.dart    # Детали теста
    │   ├── test_taking_page.dart     # Прохождение теста
    │   ├── test_results_page.dart    # Результаты
    │   ├── create_test_page.dart     # Создание теста (учитель)
    │   ├── teacher_tests_page.dart   # Управление тестами
    │   ├── test_analytics_page.dart  # Аналитика
    │   └── badges_page.dart          # Достижения
    ├── widgets/
    │   ├── test_card.dart           # Карточка теста
    │   ├── test_filters_bar.dart    # Фильтры
    │   └── stats_card.dart          # Статистика
    └── providers/
        └── test_providers.dart      # Riverpod провайдеры
```

## ✨ Основные возможности

### 🎓 Для учеников

1. **Каталог тестов**
   - Фильтры по предмету, классу, сложности
   - Сортировка (новые, популярные, рейтинг)
   - Поиск тестов
   - Статистика пользователя (очки, streak, средний балл)

2. **Прохождение тестов**
   - Три типа вопросов:
     * Множественный выбор (Multiple Choice)
     * Правда/Ложь (True/False)
     * Короткий ответ (Short Answer)
   - Таймер обратного отсчета
   - Индикатор прогресса
   - Сохранение состояния
   - Навигация между вопросами

3. **Результаты**
   - Оценка в процентах
   - Статус (Сдан/Не сдан)
   - Заработанные очки
   - Затраченное время
   - Детальный разбор ответов с пояснениями
   - Возможность повторного прохождения

4. **Геймификация**
   - Система очков
   - Бейджи:
     * 🚀 Первый шаг - первый пройденный тест
     * 🎓 Знаток тестов - 10 тестов
     * 🏆 Мастер тестов - 50 тестов
     * ⭐ Перфекционист - 100% в тесте
     * 🔥 Streak бейджи - 7, 30 дней подряд
   - Streak система (ежедневное прохождение)
   - Рейтинг по предметам

### 👨‍🏫 Для учителей

1. **Создание тестов**
   - Заголовок, описание, обложка
   - Выбор предмета и класса
   - Настройка сложности
   - Время прохождения
   - Добавление вопросов с пояснениями
   - Сохранение как черновик или публикация

2. **Управление тестами**
   - Просмотр всех созданных тестов
   - Редактирование
   - Удаление
   - Архивация

3. **Аналитика**
   - Общая статистика (попытки, средний балл, % прохождения)
   - Распределение оценок (график)
   - Производительность по вопросам
   - Список учеников с результатами
   - Определение слабых тем
   - Экспорт в CSV

## 🎨 Дизайн

Стиль вдохновлен Google Classroom и Notion:
- Чистый, минималистичный интерфейс
- Карточки с тенями
- Градиентные акценты
- Современная типографика (Montserrat)
- Адаптивная верстка

### Цветовая палитра

```dart
appPrimary = #2A3447     // Темно-синий текст
appSecondary = #707A8D   // Серый второстепенный
appAccentStart = #FF7171 // Начало градиента
appAccentEnd = #FF5050   // Конец градиента
appBackground = #F6F8FB  // Светлый фон
```

## 🔥 Firebase структура

### Collections

**tests/**
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "subject": "string",
  "gradeLevel": "number",
  "difficulty": "easy|medium|hard",
  "duration": "number (minutes)",
  "questions": [
    {
      "id": "string",
      "text": "string",
      "type": "multipleChoice|trueFalse|shortAnswer",
      "options": ["string"],
      "correctAnswer": "string",
      "explanation": "string?",
      "points": "number",
      "imageUrl": "string?"
    }
  ],
  "teacherId": "string",
  "teacherName": "string",
  "status": "draft|published|archived",
  "createdAt": "timestamp",
  "publishedAt": "timestamp?",
  "totalPoints": "number",
  "passingScore": "number",
  "tags": ["string"],
  "attempts": "number",
  "averageScore": "number",
  "coverImage": "string?"
}
```

**testAttempts/**
```json
{
  "id": "string",
  "testId": "string",
  "userId": "string",
  "userName": "string",
  "answers": {
    "questionId": "userAnswer"
  },
  "score": "number",
  "totalPoints": "number",
  "percentage": "number",
  "startedAt": "timestamp",
  "completedAt": "timestamp?",
  "timeSpent": "number (seconds)",
  "isPassed": "boolean",
  "incorrectQuestions": ["string"]
}
```

**userTestStats/**
```json
{
  "userId": "string",
  "totalTests": "number",
  "testsCompleted": "number",
  "testsPassed": "number",
  "averageScore": "number",
  "totalPoints": "number",
  "currentStreak": "number",
  "longestStreak": "number",
  "lastTestDate": "timestamp?",
  "earnedBadges": ["string"],
  "subjectScores": {
    "subject": "number"
  }
}
```

## 🚀 Использование

### Навигация

Тесты доступны через нижнюю навигацию (3-я иконка "Тесты").

### Роутинг

```dart
// В app.dart или main.dart добавьте роуты:
'/tests': (context) => TestsPage(),
'/test-details': (context) => TestDetailsPage(),
'/test-taking': (context) => TestTakingPage(),
'/test-results': (context) => TestResultsPage(),
'/create-test': (context) => CreateTestPage(),
'/teacher-tests': (context) => TeacherTestsPage(),
'/test-analytics': (context) => TestAnalyticsPage(),
'/badges': (context) => BadgesPage(),
```

### Примеры использования

```dart
// Открыть детали теста
Navigator.pushNamed(context, '/test-details', arguments: testId);

// Начать тест
Navigator.pushNamed(context, '/test-taking', arguments: test);

// Посмотреть результаты
Navigator.pushNamed(context, '/test-results', arguments: attemptId);

// Создать новый тест (учитель)
Navigator.pushNamed(context, '/create-test');
```

## 📦 Зависимости

```yaml
dependencies:
  flutter_riverpod: ^2.x.x
  google_fonts: ^5.x.x
  cloud_firestore: ^4.x.x
  firebase_auth: ^4.x.x
  fl_chart: ^1.x.x  # Для графиков в аналитике
  uuid: ^4.x.x      # Для генерации ID
```

## 🔧 Настройка Firebase

1. Создайте коллекции в Firestore
2. Установите правила безопасности:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tests/{testId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.token.role == 'teacher';
      allow update, delete: if request.auth != null && 
        resource.data.teacherId == request.auth.uid;
    }
    
    match /testAttempts/{attemptId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         request.auth.token.role == 'teacher');
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    match /userTestStats/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && userId == request.auth.uid;
    }
  }
}
```

## 🎯 Дальнейшие улучшения

- [ ] Адаптивные тесты (вопросы меняются в зависимости от ответов)
- [ ] Видео и аудио в вопросах
- [ ] Групповые тесты (соревнования)
- [ ] AI-генерация вопросов
- [ ] Расписание тестов
- [ ] Push-уведомления о новых тестах
- [ ] Социальные функции (поделиться результатом)
- [ ] Режим практики (без ограничений по времени)
- [ ] Offline режим

## 📝 Лицензия

Часть проекта EduRise Educational Platform

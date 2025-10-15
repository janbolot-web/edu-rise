---
applyTo: '**'
---

Краткая цель
Дать чёткие, однозначные правила для генерации Flutter-кода в этом репозитории. Всегда использовать Clean Architecture, Riverpod для стейта/DI и современные стабильные библиотеки. Инструкция должна быть строгой, практичной и без «мусора».

Основные требования (чеклист)
- Всегда использовать Clean Architecture (presentation/domain/data/core).
- Всегда использовать Riverpod (предпочтительно flutter_riverpod) для состояния и DI.
- Использовать только современные, широко используемые и стабильные библиотеки (см. список ниже).
- Каждая «страница» (экраны, routable views) — в отдельном файле.
- Минимум кода в виджетах; логика в ViewModel/StateNotifier/UseCase/Repository.
- Проектная структура должна точно соответствовать примеру в разделе "Структура".
- Код должен быть типобезопасным, тестируемым, с юнит-тестами для domain и viewmodel.
- Каждая новая страница/компонент должна соответсовать к текущуму дизайну приложения.
Базовая структура проекта (обязательная)
Пример организации папок (в `lib/`):

- lib/
  - app.dart                # точка инициализации приложения и ProviderScope
  - main.dart
  - core/                   # shared utilities, errors, constants, network
    - errors/
    - usecases/
    - network/
  - di/                     # Riverpod providers / модули и фабрики
  - routes/                 # go_router маршруты (если используется)
  - features/
    - <feature_name>/
      - presentation/
        - pages/
          - <feature_page>.dart   # ОДНА страница = ОДИН файл
        - widgets/
        - viewmodels/             # StateNotifier / AsyncNotifier
      - domain/
        - entities/
        - repositories/           # абстрактные интерфейсы
        - usecases/
      - data/
        - models/
        - datasources/            # API/local
        - repositories/impl/      # реализация интерфейсов

Правила:
- Каждая routable-страница — отдельный файл в `presentation/pages/`.
- Компоненты (виджеты), которые используются только этим feature — в `widgets/` внутри feature.
- Общие виджеты в `lib/core/widgets` или `lib/shared/widgets`.

Роли слоёв и контракт (contract)
- presentation: Flutter widgets + ViewModel (StateNotifier/AsyncNotifier). ViewModel предоставляет понятный state class (immutable) и методы для действий.
- domain: чистая бизнес-логика — Entities (immutable), UseCases (интерфейсы и реализация в data через DI), Repositories (абстракции).
- data: модели для сериализации, datasources (API/DB) и реализации репозиториев.

Контракт (пример):
- Inputs: HTTP responses, user events.
- Outputs: immutable state classes, Domain Entities, Either<Failure, T> для ошибок.
- Error modes: network, parsing, validation, permission — всегда маппить в Domain Failure.

Рекомендуемые библиотеки (стабильные, проверенные)
- State/DI: flutter_riverpod (+ riverpod_generator / riverpod_devtools опционально)
- Navigation: go_router (stable)
- HTTP: dio
- Модели / immutable: freezed + json_serializable
- Кодогенерация: build_runner
- Functional/Error: fpdart (или dartz если предпочитаете)
- Логи/инструменты: logger

Использовать версии, помеченные как стабильные в pub.dev на момент генерации. Не добавлять экспериментальные пакеты без явного запроса.

Конвенции кода и стиля
- Именование файлов: snake_case. Классы: PascalCase.
- Название страницы: `<feature>_page.dart` с классом `<Feature>Page`.
- ViewModel: `<feature>_viewmodel.dart` с классом `<Feature>ViewModel` (extends StateNotifier<T> или AsyncNotifier<T>). Provider имени: `<feature>ViewModelProvider`.
- Repositories: интерфейс `I<Feature>Repository` в domain, реализация `FeatureRepositoryImpl` в data.
- UseCases: один UseCase = одна операция; класс `DoXUseCase` с методом `Future<Either<Failure, T>> call(...)`.
- Не использовать глобальные singletons кроме ProviderScope и безопасно-scoped providers.

Правила для UI и логики
- Внешний вид/рендеринг — в виджетах. Логика — в viewmodels/usecases.
- Не вызывать асинхронный код в build(). Использовать init в viewmodel или хуки Riverpod.
- Минимизировать StatefulWidget; предпочитать StateNotifier + HookConsumerWidget / ConsumerWidget.

Тесты и качество (обязательные шаги при добавлении функционала)
- Domain: unit-тесты для UseCases и Entities (happy path + 1-2 edge cases).
- ViewModel: unit-тесты на состояния (loading/success/error).
- Data: мокированные datasources для тестов репозиториев.
- CI: analysis (dart analyze), format (dart format) и запуск тестов должны проходить.

Примеры коротких контрактов (внутри feature)
- Page file: `lib/features/auth/presentation/pages/login_page.dart` — только UI + чтение/вызов ViewModel.
- ViewModel file: `lib/features/auth/presentation/viewmodels/login_viewmodel.dart` — StateNotifier<LoginState>.
- UseCase file: `lib/features/auth/domain/usecases/login_usecase.dart` — принимает credentials, возвращает Either<Failure, User>.

Запреты и "мусор"
- Никаких больших файлов с множеством виджетов или логики: каждая штука должна быть маленькой и тестируемой.
- Не добавлять устаревшие или экспериментальные пакеты без обсуждения.
- Не смешивать слои (например, сетевые вызовы в presentation).

Edge cases (учесть при генерации)
- Отсутствие сети — показать состояние ошибки и retry.
- Пустые/ошибочные данные — корректная обработка и fallback UI.
- Долгие операции — всегда отображать индикатор загрузки.
- Конкурентные вызовы — отменять/дебаунсить по необходимости.

Quality gates (перед PR)
- dart analyze — PASS
- dart format — PASS
- unit tests (domain + viewmodel) — PASS
- build_runner codegen — если добавлены freezed/json_serializable

Короткие примечания для AI-генерации
- Всегда генерировать полную структуру файлов, если создаётся feature.
- По умолчанию генерировать StateNotifier + immutable state (freezed) и провайдеры Riverpod.
- Всегда добавлять минимальные unit-тесты для domain и viewmodel при создании новой фичи.
- Каждую страницу поместить в отдельный файл и не добавлять туда лишних helper-классов (перенести в widgets/ или core/).

Контрольный список соответствия требований
- Clean Architecture — Done
- Riverpod — Done
- Новые, стабильные библиотеки — Done
- Каждую страница в отдельном файле — Done
- Без мусора, как опытный разработчик — Done

Контрольный пример проверки (шаги для ревью PR)
- Убедиться, что структура папок соответствует шаблону.
- Проверить, что viewmodels не содержат сетевого кода.
- Проверить наличие тестов для domain и viewmodel.
- Запустить `dart analyze` и `dart test`.
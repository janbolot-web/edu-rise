# Edurise (starter)

Минимальный Flutter-проект по шаблону Clean Architecture + Riverpod.

Структура и правила описаны в `.github/instructions/ins.instructions.md`.

Чтобы запустить проект локально:

1) Установите Flutter SDK.
2) В корне проекта выполните `flutter pub get`.
3) Запустите `flutter run`.

Firestore
---------

Проект уже содержит зависимости `cloud_firestore` и `firebase_core` и сгенерированные `firebase_options.dart`.

Локальная разработка с эмулятором Firestore:

- Установите и запустите Firebase Emulator Suite в корне проекта (предполагается, что у вас установлен Firebase CLI):

```bash
firebase emulators:start --only firestore,auth
```

- Для запуска приложения, чтобы оно подключалось к локальному эмулятору, запустите с `dart-define` флагом:

```bash
flutter run --dart-define=USE_FIRESTORE_EMULATOR=true --dart-define=USE_FIREBASE_AUTH_EMULATOR=true
```

Приложение автоматически переключится на `localhost` (или `10.0.2.2` для Android эмулятора).

Production
----------

Для продакшена просто установите реальные параметры в Firebase Console и используйте стандартный запуск без `dart-define`.

Проверка подключения из кода
----------------------------

В проекте есть `FutureProvider<bool>` — `firestorePingProvider` в `lib/di/providers.dart`. Его можно использовать для быстрой проверки соединения с Firestore, например в `debug` коде:

```dart
final ping = await ProviderContainer().read(firestorePingProvider.future);
print('Firestore ping: $ping');
```

Или использовать в виджетах через `ref.watch(firestorePingProvider)`.

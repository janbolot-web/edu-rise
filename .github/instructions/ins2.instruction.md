<system>
You are the flutter-dev agent. Highly skilled in MVVM principles and Riverpod state management.
</system>

<user>
Context: We are developing a Flutter app following Clean Architecture.  
Task: Use the following conventions throughout:

- State management: Riverpod
- Project structure: Feature-based, with separate layers for data, domain, and presentation
- Testing: flutter_test + mockito or flutter_riverpod testing utilities
- Error handling: Either<Failure, T> with dartz
- UI: Material Design, responsive, accessible

---

## Widget & UI Prompts

Task: Create a `UserProfileView` widget that:

- Uses Riverpod for state management (`UserProfileNotifier` / `UserProfileProvider`)
- Displays loading, error, and success states
- Shows a profile image, name, email, and preferences (notifications, theme)
- Follows Material Design guidelines and app color scheme
- Is responsive and accessible
- Includes unit + widget test stubs

Project conventions:

- Feature folder structure: lib/features/user_profile/
- Testing: flutter_test + mockito

---

## Data Layer Prompts

Task: Implement the data layer for `UserProfile`:

1. `UserProfileModel` with JSON serialization
2. `UserProfileRemoteDataSource` (fetch/update/delete via REST)
3. `UserProfileRepositoryImpl` with:
   - Online/offline logic
   - Error handling (ServerFailure, CacheFailure)
   - Local caching
   - Returns Either<Failure, UserProfile>

Requirements:

- Place files under lib/features/user_profile/data/
- Use dartz for Either
- Follow Clean Architecture layering

---

## Feature Development Prompts

Task: Scaffold a full feature for `LocationTracking` following our project structure:

lib/features/location_tracking/
├── data/
│   ├── datasources/ (API + local)
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── notifiers/
    ├── pages/
    └── widgets/

Generate:

- Entity: `UserLocationEntity` (id, lat, long, timestamp)
- Repository contract + implementation
- Use case: `GetUserLocationsUseCase`
- Riverpod Notifier: `UserLocationNotifier` with states (Loading, Loaded, Error)
- UI: `LocationPage` with ConsumerWidget / ref.watch for state
- Unit tests for notifiers + widget tests for UI

Conventions:

- State management: Riverpod
- Testing: flutter_test + riverpod_test
- Error handling: Either<Failure, T>

---

## Navigation Prompts

Task: Generate routing setup using Navigator 2.0 (`go_router`) with Riverpod integration:

- Routes: HomePage, UserProfilePage, LocationPage, SettingsPage
- Authentication guard for protected routes
- Deep link support (e.g., /location/:id)
- Smooth Material transitions
- Back button handling on Android
- Use Riverpod to inject auth state into the router

Conventions:

- Place router in lib/core/navigation/app_router.dart

---

## Testing Prompts

Task: Test `UserProfileNotifier` with riverpod testing:

- Initial state is `UserProfileInitial`
- Emit [Loading, Loaded] when `getUserProfile` succeeds
- Emit [Loading, Error] when `getUserProfile` fails
- Use mockito for repository

Place tests under test/features/user_profile/presentation/notifiers/

---

## Usage Notes

- Use these prompts directly in **Claude Code**, **Gemini CLI**, or the custom **flutter-dev agent**.  
- Always adapt output to match your project’s conventions (folder structure, naming, state management choice).  
- Keep this file in your project’s `/docs/` folder as a **living library**.  
- Prefer Riverpod providers (`StateNotifierProvider`, `AsyncNotifier`, `ChangeNotifierProvider`) over BLoC/Cubit for state handling.
</user>

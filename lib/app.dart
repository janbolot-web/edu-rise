import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'widgets/main_shell.dart';
import 'features/tests/presentation/pages/test_details_page.dart';
import 'features/tests/presentation/pages/test_taking_page.dart';
import 'features/tests/presentation/pages/create_test_page.dart';
import 'features/tests/presentation/pages/teacher_tests_page.dart';
import 'features/tests/presentation/pages/test_analytics_page.dart';
import 'features/tests/presentation/pages/badges_page.dart';
import 'features/tests/presentation/pages/zipgrade_sheet_page.dart';
import 'features/tests/presentation/pages/zipgrade_scan_page.dart';

class EduriseApp extends ConsumerWidget {
  const EduriseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
  Widget home = const SplashPage();
  authAsync.when(
      data: (user) {
        home = user != null ? const MainShell() : const SplashPage();
      },
      loading: () {
        home = const SplashPage();
      },
      error: (e, st) {
        home = const MainShell();
      },
    );

    return MaterialApp(
      title: 'Edurise - Образовательная платформа',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
      home: home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/test-details':
            final testId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => TestDetailsPage(testId: testId),
            );
          case '/test-taking':
            final testId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => TestTakingPage(testId: testId),
            );
          case '/test-results':
            // TestResultsPage требует test и attempt, используем placeholder
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Результаты теста')),
              ),
            );
          case '/create-test':
            return MaterialPageRoute(
              builder: (context) => const CreateTestPage(),
            );
          case '/teacher-tests':
            return MaterialPageRoute(
              builder: (context) => const TeacherTestsPage(),
            );
          case '/test-analytics':
            final testId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => TestAnalyticsPage(testId: testId),
            );
          case '/badges':
            return MaterialPageRoute(
              builder: (context) => const BadgesPage(),
            );
          case '/zipgrade-sheet':
            return MaterialPageRoute(
              builder: (context) => const ZipgradeSheetPage(),
            );
          case '/zipgrade-scan':
            return MaterialPageRoute(
              builder: (context) => const ZipgradeScanPage(),
            );
          default:
            return null;
        }
      },
    );
  }
}

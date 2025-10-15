import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

// If you ran `flutterfire configure` this file will be generated.
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated options for the current platform.
  // Guard with catch to avoid app startup hanging if initialization is blocked.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized');
  } catch (e) {
    debugPrint('Firebase.initializeApp failed: $e');
  }

  runApp(const ProviderScope(child: EduriseApp()));
}
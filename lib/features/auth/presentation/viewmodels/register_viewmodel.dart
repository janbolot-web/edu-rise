import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

class RegisterState {
  final bool isLoading;
  RegisterState({this.isLoading = false});
  RegisterState copyWith({bool? isLoading}) => RegisterState(isLoading: isLoading ?? this.isLoading);
}

class RegisterViewModel extends StateNotifier<RegisterState> {
  RegisterViewModel(): super(RegisterState());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  /// Создаёт пользователя через Firebase Email/Password.
  /// Возвращает [UserCredential] при успехе или выбрасывает [Exception] с понятным сообщением при ошибке.
  Future<UserCredential?> register() async {
    if (state.isLoading) return null;
    state = state.copyWith(isLoading: true);
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final name = nameController.text.trim();
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email и пароль обязателены');
      }

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        // reload to ensure updated profile is available
        await user.reload();
      }
      // Ensure Firestore user document with role exists
      if (user != null) {
        await _ensureUserDoc(user);
      }
      // try to send email verification if supported
      try {
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
        }
      } catch (_) {
        // ignore verification send failures; still consider registration successful
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // map common firebase errors to friendly messages
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Пароль слишком слабый';
          break;
        case 'email-already-in-use':
          message = 'Аккаунт с таким email уже существует';
          break;
        case 'invalid-email':
          message = 'Неверный формат email';
          break;
        case 'operation-not-allowed':
          message = 'Регистрация отключена на сервере';
          break;
        default:
          message = e.message ?? 'Ошибка при регистрации';
      }
      throw Exception(message);
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Starts phone verification flow. Returns verificationId when an SMS code is sent.
  Future<String> startPhoneVerification(String phone) async {
    if (state.isLoading) return Future.value('');
    state = state.copyWith(isLoading: true);
    final completer = Completer<String>();
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval or instant verification: sign-in the user
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            // indicate immediate success with empty verificationId
            if (!completer.isCompleted) completer.complete('');
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(Exception('Phone auto-signin failed'));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) completer.completeError(Exception(e.message ?? 'Phone verification failed'));
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // timeout — do nothing, user can still enter code manually
        },
      );
    } catch (e) {
      if (!completer.isCompleted) completer.completeError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
    return completer.future;
  }

  /// Verifies SMS code with the given verificationId and smsCode and signs in the user.
  Future<UserCredential?> verifySmsCode(String verificationId, String smsCode) async {
    if (state.isLoading) return null;
    state = state.copyWith(isLoading: true);
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _ensureUserDoc(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (state.isLoading) return null;
    state = state.copyWith(isLoading: true);
    try {
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await GoogleSignIn.instance.authenticate(scopeHint: ['email', 'profile']);
      } catch (e) {
        googleUser = null;
      }
      if (googleUser == null) return null; // user cancelled
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final authz = await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);
      final credential = GoogleAuthProvider.credential(
        accessToken: authz?.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _ensureUserDoc(userCredential.user!);
      }
      return userCredential;
    } on PlatformException catch (e, st) {
      // Log full details to console for easier debugging
      debugPrint('Google sign-in PlatformException: ${e.code} ${e.message} ${e.details}');
      debugPrintStack(stackTrace: st);
      throw Exception('Platform error during Google sign-in: ${e.message ?? e.code}. Ensure platform configuration (Info.plist / URL schemes on iOS, google-services.json and SHA on Android) is set.');
    } catch (e, st) {
      debugPrint('Google sign-in error: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

extension on RegisterViewModel {
  Future<void> _ensureUserDoc(User user) async {
    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await doc.get();
      if (!snapshot.exists) {
        await doc.set({
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName ?? '',
          'phoneNumber': user.phoneNumber ?? '',
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = snapshot.data();
        if (data == null || data['role'] == null) {
          await doc.set({'role': 'user'}, SetOptions(merge: true));
        }
      }
    } catch (e) {
      // don't block auth flow on Firestore errors, but log for debugging
      debugPrint('Failed to ensure user doc: $e');
    }
  }
}

final registerViewModelProvider = StateNotifierProvider<RegisterViewModel, RegisterState>((ref) {
  final vm = RegisterViewModel();
  ref.onDispose(() {
    vm.nameController.dispose();
    vm.emailController.dispose();
    vm.passwordController.dispose();
  vm.phoneController.dispose();
  });
  return vm;
});

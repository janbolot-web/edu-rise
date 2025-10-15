import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  final bool isLoading;
  LoginState({this.isLoading = false});
  LoginState copyWith({bool? isLoading}) => LoginState(isLoading: isLoading ?? this.isLoading);
}

class LoginViewModel extends Notifier<LoginState> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  LoginState build() {
    ref.onDispose(() {
      emailController.dispose();
      passwordController.dispose();
    });
    return LoginState();
  }

  Future<void> login() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      // try firebase auth if configured
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      // fallback / handle error
    }
    state = state.copyWith(isLoading: false);
  }
}

final loginViewModelProvider = NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);

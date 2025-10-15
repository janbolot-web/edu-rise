import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SplashState { loading, ready }

class SplashViewModel extends Notifier<SplashState> {
  @override
  SplashState build() {
    _init();
    return SplashState.loading;
  }

  Future<void> _init() async {
    // simulate initialization, load config, etc.
    await Future.delayed(const Duration(seconds: 2));
    state = SplashState.ready;
  }
}

final splashViewModelProvider = NotifierProvider<SplashViewModel, SplashState>(SplashViewModel.new);

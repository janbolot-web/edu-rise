import 'package:edurise/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:edurise/core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _slide = Tween<Offset>(begin: const Offset(0, 2.9), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // center rocket + Rive flame (only Rive animates)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: size.width,
                    height: size.width,
                    child: const rive.RiveAnimation.asset(
                        'assets/animations/rocket_flame.riv',
                        fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
          ),

          // bottom card with text and button (animated entrance)
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: Container(
                  height: size.height * 0.45,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 44),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Launch and Grow your startup',
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: appPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                          'The average company forecasts a growth 178% in revenues for their first year, 100% for second, and 71% for third.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              color: appSecondary,
                              fontSize: 16)),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [appAccentStart, appAccentEnd],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius:
                              BorderRadius.circular(30), // под StadiumBorder
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const RegisterPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent, // прозрачный фон
                            shadowColor: Colors.transparent, // убрать тень
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 120, vertical: 14),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Montserrat",
                                fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(loginViewModelProvider);
    final notifier = ref.read(loginViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.arrow_back, color: appPrimary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Sign in',
                        style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: appPrimary)),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              Text('Welcome back',
                  style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: appPrimary)),
              const SizedBox(height: 8),
              Text('Sign in to continue to your courses',
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: appSecondary)),

              const SizedBox(height: 24),

              _InputField(
                label: 'Email',
                hint: 'you@mail.com',
                controller: notifier.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _InputField(
                label: 'Password',
                hint: '••••••••',
                controller: notifier.passwordController,
                obscureText: true,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: null,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                  ),
                  onPressed: vm.isLoading ? null : () => notifier.login(),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [appAccentStart, appAccentEnd]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 56,
                      child: vm.isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : Text('Sign in',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                    onPressed: () {
                      // TODO: navigate to register
                    },
                    child: Text('Don\'t have an account? Create one',
                        style: GoogleFonts.montserrat(color: appSecondary))),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _InputField({required this.label, required this.hint, required this.controller, this.obscureText = false, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(color: appPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: GoogleFonts.montserrat(color: const Color(0xFFBEC8D6))),
          ),
        )
      ],
    );
  }
}

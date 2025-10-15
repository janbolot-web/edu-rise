import 'package:edurise/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../viewmodels/register_viewmodel.dart';
import 'package:edurise/widgets/main_shell.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(registerViewModelProvider);
  final notifier = ref.read(registerViewModelProvider.notifier);

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
                    child: Text('Create account',
                        style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: appPrimary)),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              Text('Welcome to EduRise',
                  style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: appPrimary)),
              _InputField(
                label: 'Phone',
                hint: '+7 900 000 0000',
                controller: notifier.phoneController,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: null,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                  ),
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final phone = notifier.phoneController.text.trim();
                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите номер телефона')));
                            return;
                          }

                          try {
                            final verificationId = await notifier.startPhoneVerification(phone);
                            if (verificationId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone sign-in completed automatically')));
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (route) => false);
                              return;
                            }

                            final smsCode = await showDialog<String?>(
                              context: context,
                              builder: (ctx) {
                                final controller = TextEditingController();
                                return AlertDialog(
                                  title: const Text('Enter SMS code'),
                                  content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '123456')),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Verify')),
                                  ],
                                );
                              },
                            );

                            if (smsCode == null || smsCode.isEmpty) return;
                            final userCred = await notifier.verifySmsCode(verificationId, smsCode);
                            if (userCred != null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone sign-in successful')));
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (route) => false);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [appAccentStart, appAccentEnd]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 56,
                      child: vm.isLoading ? const CircularProgressIndicator.adaptive() : Text('Create account', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final phone = notifier.phoneController.text.trim();
                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите номер телефона')));
                            return;
                          }

                          try {
                            final verificationId = await notifier.startPhoneVerification(phone);
                            // If verificationId is empty string, auto-retrieval completed and user signed in.
                            if (verificationId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone sign-in completed automatically')));
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (route) => false);
                              return;
                            }

                            // Ask user for SMS code
                            final smsCode = await showDialog<String?>(
                              context: context,
                              builder: (ctx) {
                                final controller = TextEditingController();
                                return AlertDialog(
                                  title: const Text('Enter SMS code'),
                                  content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '123456')),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Verify')),
                                  ],
                                );
                              },
                            );

                            if (smsCode == null || smsCode.isEmpty) return;
                            final userCred = await notifier.verifySmsCode(verificationId, smsCode);
                            if (userCred != null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone sign-in successful')));
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (route) => false);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        },
                  child: Text('Sign up with phone', style: GoogleFonts.montserrat(color: appPrimary)),
                ),
              ),

              const SizedBox(height: 16),
              Center(child: Text('Or sign up with', style: GoogleFonts.montserrat(color: appSecondary))),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: Image.asset('assets/images/google_logo.png', width: 20, height: 20),
                  label: Text('Sign up with Google', style: GoogleFonts.montserrat(color: appPrimary)),
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final useMock = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Google Sign-In'),
                              content: const Text('Use real Google Sign-In (requires platform config) or a safe mock to continue without native setup?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Real')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Use mock')),
                              ],
                            ),
                          );
                          if (useMock == null) return; // dialog dismissed
                          if (useMock) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock sign-in successful')));
                            return;
                          }
                          try {
                            final res = await notifier.signInWithGoogle();
                            if (res != null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in with Google')));
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (route) => false);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
                          }
                        },
                ),
              ),

              Center(
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                    },
                    child: Text('Already have an account? Sign in',
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
  final TextInputType? keyboardType;

  const _InputField({required this.label, required this.hint, required this.controller, this.keyboardType});

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
            obscureText: false,
            keyboardType: keyboardType,
            decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: GoogleFonts.montserrat(color: const Color(0xFFBEC8D6))),
          ),
        )
      ],
    );
  }
}

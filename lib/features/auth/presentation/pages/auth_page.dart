import 'package:edurise/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Widget getCountryFlag(String countryCode) {
  String flag = countryCode.toUpperCase().replaceAllMapped(
    RegExp(r'[A-Z]'),
    (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
  );
  return Text(
    flag,
    style: const TextStyle(fontSize: 20),
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late Country _selectedCountry;
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
  GoogleSignInAccount? googleUser;
  try {
    // interactive authentication via package API
    googleUser = await GoogleSignIn.instance.authenticate(scopeHint: ['email', 'profile']);
  } catch (e) {
    // authentication failed or was cancelled
    googleUser = null;
  }
      if (googleUser == null) {
        // User cancelled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
      }

  // authentication is a synchronous getter returning tokens available at auth time
  final GoogleSignInAuthentication googleAuth = googleUser.authentication;
  final String? idToken = googleAuth.idToken;
  // request an authorization client token (access token) for scopes if available
  final authz = await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);
  final String? accessToken = authz?.accessToken;

      if (idToken == null && accessToken == null) {
        throw Exception('Missing Google authentication tokens');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Вход выполнен: ${userCredential.user?.displayName ?? userCredential.user?.email}')),
        );
      }
      // TODO: Навигация после успешного входа
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка входа: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country(
      phoneCode: "996",
      countryCode: "KG",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "Kyrgyzstan",
      example: "996 XXX XXX XXX",
      displayName: "Kyrgyzstan",
      displayNameNoCountryCode: "KG",
      e164Key: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      'assets/images/google_logo.png',
                      height: 50,
                    ),
                  ),

                  // Welcome Text
                  const Text(
                    'Hi, Welcome! 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Пожалуйста, подтвердите код страны и\nвведите номер телефона.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Country and Phone Input Fields
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Country Selection
                        InkWell(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                              countryListTheme: CountryListThemeData(
                                bottomSheetHeight: MediaQuery.of(context).size.height * 0.6,
                                borderRadius: BorderRadius.circular(12),
                                inputDecoration: InputDecoration(
                                  hintText: 'Поиск страны',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                    ),
                                  ),
                                ),
                              ),
                              onSelect: (Country country) {
                                setState(() {
                                  _selectedCountry = country;
                                });
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Flag
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                    child: getCountryFlag(_selectedCountry.countryCode),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedCountry.displayNameNoCountryCode,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF999999),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Divider
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE0E0E0),
                        ),
                        // Phone Input
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Country Code
                              Text(
                                '+${_selectedCountry.phoneCode}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Phone Number Input
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '000 00 00 00',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF999999),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Remember me & Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: appAccentEnd,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Запомнить меня',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: appAccentEnd,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Забыли пароль?',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appAccentEnd,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: const Text(
                      'Войти',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Or with
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Или с',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social Login Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A1A1A),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.facebook,
                            color: Color(0xFF1877F2),
                            size: 24,
                          ),
                          label: const Text(
                            'Facebook',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A1A1A),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 24,
                                  height: 24,
                                ),
                          label: const Text(
                            'Google',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Нет аккаунта? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: appAccentEnd,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Зарегистрироваться',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

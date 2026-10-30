
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// Class untuk halaman Login.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Class untuk mengatur state dan isi halaman Login.
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController =
  TextEditingController();
  final TextEditingController passwordController =
  TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color navy = Color(0xFF172B4D);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F6FA);

  Future<void> login() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.login(
        identifier: usernameController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 35, 28, 45),
                decoration: const BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'SCHOOL ADMIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 35),
                    Text(
                      'Selamat Datang!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Silakan masuk untuk mengelola\ninformasi sekolah Anda.',
                      style: TextStyle(
                        color: Color(0xFFD5DEED),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Login Akun',
                            style: TextStyle(
                              color: navy,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Masukkan username atau email dan password.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Username atau Email',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: usernameController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hint: 'Masukkan username atau email',
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username atau email wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Password',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => login(),
                            decoration: _inputDecoration(
                              hint: 'Masukkan password',
                              icon: Icons.lock_outline_rounded,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                blue.withValues(alpha: 0.6),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                                  : const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Login Sekarang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),
                          const Center(
                            child: Text(
                              'Sistem Informasi Sekolah',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: blue),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
    );
  }
}

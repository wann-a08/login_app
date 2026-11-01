import 'package:flutter/material.dart';

import '../core/app_session.dart';
import '../services/api_client.dart';

// Halaman login admin; tidak menyediakan registrasi publik.
class LoginPage extends StatefulWidget {
  final AppSession session;
  const LoginPage({super.key, required this.session});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() => _loading = true);
    try {
      await widget.session.login(
        identifier: _identifier.text.trim(),
        password: _password.text,
      );
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on ApiException catch (error) {
      if (!mounted) return;
      final message = error.statusCode == 401
          ? 'Username/email atau password salah.'
          : error.statusCode == 429
              ? 'Terlalu banyak percobaan login. Coba lagi beberapa saat.'
              : error.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red.shade700));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login gagal. Periksa koneksi dan server.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF172B4D);
    const background = Color(0xFFF4F6FA);
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.school_rounded, size: 48, color: navy),
                        const SizedBox(height: 12),
                        const Text('SCHOOL ADMIN', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: navy)),
                        const SizedBox(height: 8),
                        const Text('Login untuk melanjutkan ke dashboard.', textAlign: TextAlign.center),
                        if (widget.session.sessionExpired) ...[
                          const SizedBox(height: 16),
                          const Text('Sesi habis. Silakan login kembali.', style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                        ],
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _identifier,
                          decoration: const InputDecoration(labelText: 'Username atau email', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Username/email wajib diisi.' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure)),
                          ),
                          onFieldSubmitted: (_) => _login(),
                          validator: (v) => v == null || v.isEmpty ? 'Password wajib diisi.' : null,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _loading ? null : _login,
                          style: FilledButton.styleFrom(backgroundColor: navy, padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

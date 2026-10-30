
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Class untuk mengelola autentikasi ke REST API.
class AuthService {
  static const String baseUrl = 'http://localhost:3000/api';

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  // Mengirim username/email dan password ke API login.
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    final response = await http
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    )
        .timeout(const Duration(seconds: 15));

    final Map<String, dynamic> result;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format respons API tidak valid.');
      }

      result = decoded;
    } on FormatException {
      throw Exception(
        'Respons API bukan JSON yang valid '
            '(HTTP ${response.statusCode}).',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        result['success'] == true) {
      final data = result['data'];

      if (data is! Map<String, dynamic> ||
          data['token'] is! String ||
          (data['token'] as String).isEmpty) {
        throw Exception('Respons login tidak memuat token yang valid.');
      }

      await _storage.write(
        key: _tokenKey,
        value: data['token'] as String,
      );

      return data;
    }

    final message = result['message']?.toString() ??
        'Login gagal (HTTP ${response.statusCode}).';

    throw Exception(message);
  }

  // Mengambil JWT yang tersimpan.
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  // Menghapus JWT saat logout.
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}

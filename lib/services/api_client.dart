import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Exception terstruktur untuk error HTTP, validasi, dan jaringan.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, String> fieldErrors;

  const ApiException({
    this.statusCode,
    required this.message,
    this.fieldErrors = const {},
  });

  @override
  String toString() => message;
}

// Satu pintu komunikasi HTTP agar token, timeout, dan error konsisten.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const Duration _timeout = Duration(seconds: 12);
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000/api',
  );

  // Diatur oleh pengelola sesi; tidak membutuhkan BuildContext.
  VoidCallback? onUnauthorized;
  bool _handlingUnauthorized = false;

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<dynamic> get(String path,
      {Map<String, String>? query, bool authenticated = true}) =>
      request('GET', path, query: query, authenticated: authenticated);

  Future<dynamic> post(String path, {Object? body, bool authenticated = true}) =>
      request('POST', path, body: body, authenticated: authenticated);

  Future<dynamic> put(String path, {Object? body, bool authenticated = true}) =>
      request('PUT', path, body: body, authenticated: authenticated);

  Future<dynamic> delete(String path, {bool authenticated = true}) =>
      request('DELETE', path, authenticated: authenticated);

  Future<dynamic> request(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await readToken();
      if (token == null || token.isEmpty) {
        await _handleUnauthorized();
        throw const ApiException(statusCode: 401, message: 'Sesi habis. Silakan login kembali.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      late http.Response response;
      final encodedBody = body == null ? null : jsonEncode(body);
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: encodedBody).timeout(_timeout);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: encodedBody).timeout(_timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(_timeout);
          break;
        default:
          throw ArgumentError('Metode HTTP tidak didukung: $method');
      }

      if (response.statusCode == 204) return null;

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          throw const ApiException(message: 'Format respons server tidak valid.');
        }
        decoded = null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic> && decoded['success'] == false) {
          throw ApiException(
            statusCode: response.statusCode,
            message: decoded['message']?.toString() ?? 'Permintaan gagal.',
          );
        }
        return decoded;
      }

      final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      if (response.statusCode == 401 && authenticated) {
        await _handleUnauthorized();
      }
      final errors = <String, String>{};
      final rawErrors = map['errors'];
      if (rawErrors is List) {
        for (final item in rawErrors) {
          if (item is Map) {
            final field = item['field']?.toString();
            final message = item['message']?.toString();
            if (field != null && message != null) errors[field] = message;
          }
        }
      }
      final fallback = switch (response.statusCode) {
        401 => 'Sesi habis. Silakan login kembali.',
        409 => 'Data bertentangan dengan data yang sudah ada.',
        422 => 'Periksa kembali data yang dimasukkan.',
        429 => 'Terlalu banyak percobaan. Coba lagi beberapa saat.',
        _ => 'Permintaan gagal (HTTP ${response.statusCode}).',
      };
      throw ApiException(
        statusCode: response.statusCode,
        message: map['message']?.toString() ?? fallback,
        fieldErrors: errors,
      );
    } on TimeoutException {
      throw const ApiException(message: 'Permintaan ke server melewati batas waktu. Periksa koneksi dan server.');
    } on http.ClientException {
      throw const ApiException(message: 'Tidak dapat terhubung ke server. Periksa alamat API dan koneksi jaringan.');
    } on FormatException {
      throw const ApiException(message: 'Format respons server tidak valid.');
    }
  }

  Future<void> _handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    try {
      await clearToken();
      onUnauthorized?.call();
    } finally {
      _handlingUnauthorized = false;
    }
  }
}

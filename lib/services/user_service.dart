import 'dart:convert';
import 'package:http/http.dart' as http;

// Class untuk mengambil data user dan pagination dari REST API.
class UserService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/users').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception('Respons API bukan JSON yang valid.');
    }

    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? 'Gagal mengambil data user'
          : 'Gagal mengambil data user';

      throw Exception(message);
    }

    if (decoded is! Map<String, dynamic> ||
        decoded['success'] != true ||
        decoded['data'] is! List ||
        decoded['meta'] is! Map<String, dynamic>) {
      throw Exception('Format respons API tidak valid.');
    }

    final meta = decoded['meta'] as Map<String, dynamic>;

    return {
      'data': (decoded['data'] as List)
          .map((user) => Map<String, dynamic>.from(user as Map))
          .toList(),
      'page': (meta['page'] as num).toInt(),
      'limit': (meta['limit'] as num).toInt(),
      'total': (meta['total'] as num).toInt(),
      'totalPages': (meta['totalPages'] as num).toInt(),
    };
  }
}

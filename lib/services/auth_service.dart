import 'api_client.dart';
import '../models/auth_user.dart';

// Class untuk login, validasi sesi, dan logout admin.
class AuthService {
  final ApiClient _api = ApiClient.instance;

  Future<AuthUser> login({
    required String identifier,
    required String password,
  }) async {
    final result = await _api.post(
      '/auth/login',
      authenticated: false,
      body: {'identifier': identifier, 'password': password},
    );
    final data = _requireData(result);
    final token = data['token'];
    if (token is! String || token.isEmpty) {
      throw const ApiException(message: 'Respons login tidak memuat token yang valid.');
    }
    await _api.saveToken(token);
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw const ApiException(message: 'Data admin pada respons login tidak valid.');
    }
    return AuthUser.fromJson(user);
  }

  Future<AuthUser> currentUser() async {
    final result = await _api.get('/auth/me');
    final data = _requireData(result);
    return AuthUser.fromJson(data);
  }

  Future<void> logout() => _api.clearToken();

  Map<String, dynamic> _requireData(dynamic result) {
    if (result is! Map<String, dynamic> || result['data'] is! Map) {
      throw const ApiException(message: 'Format respons API tidak valid.');
    }
    return Map<String, dynamic>.from(result['data'] as Map);
  }
}

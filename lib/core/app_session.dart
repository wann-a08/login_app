import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'app_navigator.dart';

// State sesi aplikasi; lapisan API dapat memberi tahu saat menerima HTTP 401.
class AppSession extends ChangeNotifier {
  AppSession() {
    ApiClient.instance.onUnauthorized = _onUnauthorized;
  }

  final AuthService _auth = AuthService();
  AuthUser? user;
  bool isChecking = true;
  bool get isAuthenticated => user != null;
  bool sessionExpired = false;

  Future<void> restore() async {
    isChecking = true;
    notifyListeners();
    try {
      final token = await ApiClient.instance.readToken();
      if (token == null || token.isEmpty) {
        user = null;
      } else {
        user = await _auth.currentUser();
      }
    } catch (_) {
      await ApiClient.instance.clearToken();
      user = null;
    } finally {
      isChecking = false;
      notifyListeners();
    }
  }

  Future<void> login({required String identifier, required String password}) async {
    user = await _auth.login(identifier: identifier, password: password);
    sessionExpired = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    user = null;
    sessionExpired = false;
    notifyListeners();
  }

  void _onUnauthorized() {
    user = null;
    sessionExpired = true;
    notifyListeners();
    appNavigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
  }
}

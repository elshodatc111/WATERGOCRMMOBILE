import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:water_go/const/api_const.dart';

enum AuthStatus {
  noToken, // Token yo'q → Login
  tokenInvalid, // Token aktiv emas → Login
  currer, // Token aktiv + type = currer → CurrerMainScreen
  ombor, // Token aktiv + type != currer → OmborMainScreen
}

class AuthService {
  final GetStorage _storage = GetStorage();

  Future<AuthStatus> checkAuth() async {
    final token = _storage.read('auth_token');
    if (token == null || token.toString().isEmpty) {
      return AuthStatus.noToken;
    }
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConst.baseUrl}/auth/check'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final type = _storage.read('type') ?? data['type'] ?? '';
        if (type == 'currer') {
          return AuthStatus.currer;
        } else {
          return AuthStatus.ombor;
        }
      } else {
        _storage.remove('auth_token');
        _storage.remove('type');
        return AuthStatus.tokenInvalid;
      }
    } catch (e) {
      final type = _storage.read('type') ?? '';
      if (type == 'currer') return AuthStatus.currer;
      if (type.isNotEmpty) return AuthStatus.ombor;
      return AuthStatus.tokenInvalid;
    }
  }
}

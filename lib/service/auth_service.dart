import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:water_go/const/api_const.dart';
import 'package:water_go/models/ish_haqi_model.dart';
import 'package:water_go/models/user_model.dart';
import 'package:water_go/service/fcm_service.dart';

enum AuthStatus {noToken,  tokenInvalid,  currer,  ombor, operator, admin}
class AuthService {
  final GetStorage _storage = GetStorage();
  static const String _tokenKey = 'auth_token';
  static const String _typeKey = 'auth_type';
  static const String _userKey = 'auth_user';

  Future<AuthStatus> checkAuth() async {
    final token = _storage.read<String>(_tokenKey);
    if (token == null || token.isEmpty) {
      return AuthStatus.noToken;
    }
    try {
      final response = await http.get(
            Uri.parse('${ApiConst.baseUrl}/auth/check'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final type = data['type']?.toString() ?? getType() ?? '';
        _storage.write(_typeKey, type);
        return type == 'currer' ?
          AuthStatus.currer : (type == 'omborchi' ?
            AuthStatus.ombor: (type == 'operator' ?
              AuthStatus.operator: (type == 'operator' ?
                AuthStatus.operator: AuthStatus.admin)));
      } else {
        _clearAll();
        return AuthStatus.tokenInvalid;
      }
    } catch (_) {
      final type = getType() ?? '';
      if (type == 'currer') return AuthStatus.currer;
      if (type == 'omborchi') return AuthStatus.ombor;
      if (type == 'operator') return AuthStatus.operator;
      if (type.isNotEmpty) return AuthStatus.admin;
      return AuthStatus.tokenInvalid;
    }
  }

  Future<LoginResponse> login({required String phone,required String password,}) async {
    try {
      print('✅ Token saqlandi: ${_storage.read('fcm_token')}');
      final response = await http.post(
            Uri.parse('${ApiConst.baseUrl}/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'phone': phone, 'password': password}),
          ).timeout(const Duration(seconds: 30));
      final Map<String, dynamic> data = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(data);
      if (loginResponse.success && loginResponse.token != null) {
        _storage.write(_tokenKey, loginResponse.token);
        _storage.write(_typeKey, loginResponse.type ?? '');
        if (loginResponse.user != null) {
          _storage.write(_userKey, jsonEncode(loginResponse.user!.toJson()));
        }
        print('✅ Token saqlandi: ${_storage.read(_tokenKey)}');
        final fcmService = FCMService();
        await fcmService.sendTokenAfterLogin();
      }
      return loginResponse;
    } on SocketException {
      throw AuthException('Internet aloqasi mavjud emas');
    } on HttpException {
      throw AuthException('Server bilan ulanishda xatolik');
    } on FormatException {
      throw AuthException('Serverdan noto\'g\'ri javob keldi');
    } catch (e) {
      throw AuthException('Kutilmagan xatolik: $e');
    }
  }

  Future<bool> logout() async {
    try {
      final token = getToken();
      if (token != null) {
        await http.post(
              Uri.parse('${ApiConst.baseUrl}/auth/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            ).timeout(const Duration(seconds: 15));
      }
    } catch (_) {
    } finally {
      _clearAll();
    }
    return true;
  }

  Future<UserModel?> getProfile() async {
    try {
      final token = getToken();
      if (token == null) return null;
      final response = await http.get(
            Uri.parse('${ApiConst.baseUrl}/auth/profile'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return UserModel.fromJson(data['user']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<IshHaqiModel>?> getPayment() async {
    try {
      final token = getToken();
      if (token == null) return null;
      final response = await http.get(
        Uri.parse('${ApiConst.baseUrl}/auth/payment'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['payment'] != null) {
          // Listni xavfsiz Map qilib olish
          final List list = data['payment'] ?? [];
          return list.map((e) => IshHaqiModel.fromJson(e)).toList();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> passwordUpdate(String current_password,String new_password,String new_password_confirmation,) async {
    try {
      final token = getToken();
      if (token == null) {throw AuthException('Avtorizatsiya belgisi topilmadi. Tizimga qayta kiring.');}
      final response = await http.post(
        Uri.parse('${ApiConst.baseUrl}/auth/password/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': current_password,
          'new_password': new_password,
          'new_password_confirmation': new_password_confirmation,
        }),
      ).timeout(const Duration(seconds: 15));
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return;
        }
        throw AuthException(data['message'] ?? 'Parolni yangilab bo\'lmadi');
      } else {
        throw AuthException(data['message'] ?? 'Server xatoligi: ${response.statusCode}');
      }
    } on SocketException {
      throw AuthException('Internet aloqasi mavjud emas');
    } on HttpException {
      throw AuthException('Server bilan ulanishda xatolik yuz berdi');
    } on FormatException {
      throw AuthException('Serverdan noto\'g\'ri formatda javob keldi');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Kutilmagan xatolik yuz berdi: $e');
    }
  }

  String? getToken() => _storage.read<String>(_tokenKey);
  String? getType() => _storage.read<String>(_typeKey);
  bool isLoggedIn() => (getToken() ?? '').isNotEmpty;
  UserModel? getCachedUser() {
    final userStr = _storage.read<String>(_userKey);
    if (userStr == null) return null;
    return UserModel.fromJson(jsonDecode(userStr));
  }

  void _clearAll() {
    _storage.remove(_tokenKey);
    _storage.remove(_typeKey);
    _storage.remove(_userKey);
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

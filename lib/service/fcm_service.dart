import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:water_go/const/api_const.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GetStorage _storage = GetStorage();

  Future<String?> getToken() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      print("✅ FCM Token: $token");
      if (token != null) {
        _storage.write('fcm_token', token);
      }
      return token;
    }
    print('❌ Notification ruxsati berilmadi');
    return null;
  }

  Future<void> sendTokenAfterLogin() async {
    final authToken = _storage.read('auth_token');
    final fcmToken = _storage.read('fcm_token');
    if (authToken == null || fcmToken == null) {
      print('⏳ auth_token yoki fcm_token yo\'q, skip');
      return;
    }
    await sendTokenToServer(fcmToken);
  }

  void onTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔄 Token yangilandi: $newToken');
      _storage.write('fcm_token', newToken);
      final authToken = _storage.read('auth_token');
      if (authToken != null) {
        sendTokenToServer(newToken);
      }
    });
  }

  /*
  * final FCMService _fcmService = FCMService();
  * await _fcmService.sendTokenAfterLogin();
  * */

  Future<void> sendTokenToServer(String token) async {
    final authToken = _storage.read('auth_token');
    if (authToken == null) {
      print('⏳ auth_token yo\'q, serverga yuborilmadi');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('${ApiConst.baseUrl}/save-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcm_token': token}),
      );
      if (response.statusCode == 200) {
        print('✅ Token serverga yuborildi');
      } else {
        print('❌ Server xatolik: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network xatolik: $e');
    }
  }
}
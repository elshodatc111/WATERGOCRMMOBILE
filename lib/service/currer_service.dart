import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:water_go/const/api_const.dart';
import 'package:water_go/models/chat_model.dart';
import 'package:water_go/models/order_detal_model.dart';
import 'package:water_go/models/order_model.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class CurrerService {
  static String _baseUrl = ApiConst.baseUrl;

  final http.Client _client;
  final String token;

  CurrerService({required this.token, http.Client? client}): _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  Never _handleError(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = {'message': response.body};
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: body['message'] ?? 'Noma\'lum xato',
    );
  }

  // ──────────────────────────────────────────────
  // GET /currer/home
  // Kuryer hududidagi yangi buyurtmalar ro'yxati
  // ──────────────────────────────────────────────

  Future<List<OrderModel>> getHomeOrders() async {
    final uri = Uri.parse('$_baseUrl/currer/home');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List orders = data['orders'] ?? [];
      return orders.map((e) => OrderModel.fromJson(e)).toList();
    }
    _handleError(response);
  }

  Future<OrderDetailModel> getOrderDetail(int id) async {
    final uri = Uri.parse('$_baseUrl/currer/home/show/$id');
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final order = OrderModel.fromJson(data['order']);
      final List chatList = data['chat'] ?? [];
      final chats = chatList.map((e) => ChatModel.fromJson(e)).toList();
      return OrderDetailModel(order: order, chats: chats);
    }
    _handleError(response);
  }

  Future<void> acceptOrder(int orderId) async {
    final uri = Uri.parse('$_baseUrl/currer/home/show/pending');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode({'order_id': orderId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) return;
      throw ApiException(
        statusCode: 200,
        message: data['message'] ?? 'Buyurtma qabul qilinmadi',
      );
    }
    _handleError(response);
  }

  Future<ChatModel> sendChatMessage({required int orderId,required String message,}) async {
    final uri = Uri.parse('$_baseUrl/currer/home/show/chat');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'order_id': orderId,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        final raw = data['chat'] as Map<String, dynamic>;
        return ChatModel(
          message: raw['message'],
          user: raw['user_id']?.toString() ?? '',
          date: raw['created_at'] ?? '',
        );
      }
      throw ApiException(statusCode: 200, message: 'Xabar yuborilmadi');
    }
    _handleError(response);
  }
  void dispose() => _client.close();
}
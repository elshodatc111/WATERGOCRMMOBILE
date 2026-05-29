import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:water_go/const/api_const.dart';
import 'package:water_go/models/currer/currer_active_detal_model.dart';
import 'package:water_go/models/currer/currer_active_price_model.dart';
import 'package:water_go/models/currer/currer_aktive_model.dart';
import 'package:water_go/models/currer/currer_chat_model.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class CurrerActiveService {
  static String _baseUrl = ApiConst.baseUrl;
  final http.Client _client;
  final String token;

  CurrerActiveService({required this.token, http.Client? client})
    : _client = client ?? http.Client();

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

  Future<List<CurrerAktiveModel>> getAktivOrders() async {
    final uri = Uri.parse('$_baseUrl/currer/order');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List orders = data['orders'] ?? [];
      return orders.map((e) => CurrerAktiveModel.fromJson(e)).toList();
    }
    _handleError(response);
  }

  Future<CurrerActiveDetalModel> getOrderDetail(int id) async {
    final uri = Uri.parse('$_baseUrl/currer/order/show/$id');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final order = CurrerAktiveModel.fromJson(data['order']);
      final List chatList = data['chat'] ?? [];
      final chats = chatList.map((e) => CurrerChatModel.fromJson(e)).toList();
      final List priceList = data['price'] ?? [];
      final price = priceList.map((e) => CurrerActivePriceModel.fromJson(e)).toList();
      return CurrerActiveDetalModel(order: order, chats: chats, price: price);
    }
    _handleError(response);
  }

  Future<void> acceptOrder(
      int orderId,
      int cash,
      int card,
      int bank,
      int full_contaner,
      int empty_contaner
      ) async {
    final uri = Uri.parse('$_baseUrl/currer/order/success');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(
          {
            'order_id': orderId,
            'cash': cash,
            'card': card,
            'bank': bank,
            'full_contaner': full_contaner,
            'empty_contaner': empty_contaner,
          }
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) return;
      throw ApiException(
        statusCode: 200,
        message: data['message'] ?? 'Buyurtma mofaqiyatli bajarildi',
      );
    }
    _handleError(response);
  }

  Future<CurrerChatModel> sendChatMessage({
    required int orderId,
    required String message,
  }) async {
    final uri = Uri.parse('$_baseUrl/currer/home/show/chat');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode({'order_id': orderId, 'message': message}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        final raw = data['chat'] as Map<String, dynamic>;
        return CurrerChatModel(
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

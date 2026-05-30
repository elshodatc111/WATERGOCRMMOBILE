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
  static final String _baseUrl = ApiConst.baseUrl;
  final http.Client _client;
  final String token;

  CurrerActiveService({required this.token, http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  dynamic _parseResponseBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {'message': body};
    }
  }

  Future<List<CurrerAktiveModel>> getAktivOrders() async {
    final uri = Uri.parse('$_baseUrl/currer/order');
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List orders = [];
      if (data is List) {
        orders = data;
      } else if (data is Map) {
        final val = data['orders'];
        if (val is List) {
          orders = val;
        } else if (val is Map) {
          orders = [val];
        }
      }
      return orders.map((e) => CurrerAktiveModel.fromJson(e)).toList();
    }

    final body = _parseResponseBody(response.body);
    throw ApiException(statusCode: response.statusCode, message: body['message'] ?? 'Noma\'lum xato');
  }

  Future<List<CurrerAktiveModel>> getHistoryOrders() async {
    final uri = Uri.parse('$_baseUrl/currer/order/history');
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List orders = [];
      if (data is List) {
        orders = data;
      } else if (data is Map) {
        final val = data['orders'];
        if (val is List) {
          orders = val;
        } else if (val is Map) {
          orders = [val];
        }
      }
      return orders.map((e) => CurrerAktiveModel.fromJson(e)).toList();
    }

    final body = _parseResponseBody(response.body);
    throw ApiException(statusCode: response.statusCode, message: body['message'] ?? 'Noma\'lum xato');
  }

  Future<CurrerActiveDetalModel> getOrderDetail(int id) async {
    final uri = Uri.parse('$_baseUrl/currer/order/show/$id');
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final orderRaw = data['order'];
      final CurrerAktiveModel order;
      if (orderRaw is List) {
        order = CurrerAktiveModel.fromJson(orderRaw.first as Map<String, dynamic>);
      } else {
        order = CurrerAktiveModel.fromJson(orderRaw as Map<String, dynamic>);
      }

      final chatRaw = data['chat'];
      final List chatList = chatRaw is List ? chatRaw : (chatRaw != null ? [chatRaw] : []);
      final chats = chatList.map((e) => CurrerChatModel.fromJson(e)).toList();

      final priceRaw = data['price'];
      final List priceList = priceRaw is List ? priceRaw : (priceRaw != null ? [priceRaw] : []);
      final price = priceList.map((e) => CurrerActivePriceModel.fromJson(e)).toList();

      return CurrerActiveDetalModel(order: order, chats: chats, price: price);
    }

    final body = _parseResponseBody(response.body);
    throw ApiException(statusCode: response.statusCode, message: body['message'] ?? 'Noma\'lum xato');
  }

  Future<void> acceptOrder(int orderId, int cash, int card, int bank, int full_contaner, int empty_contaner) async {
    final uri = Uri.parse('$_baseUrl/currer/order/success');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'order_id': orderId,
        'cash': cash,
        'card': card,
        'bank': bank,
        'full_contaner': full_contaner,
        'empty_contaner': empty_contaner,
      }),
    );
    final data = _parseResponseBody(response.body);
    if (response.statusCode == 200) {
      if (data is Map && (data['success'] == true ||
          (data['message'] != null && data['message'].toString().toLowerCase().contains('muvaffaqiyatli')))) {
        return; // Muvaffaqiyatli deb hisoblaymiz va UI dagi await tugaydi!
      }
      throw ApiException(
        statusCode: 200,
        message: (data is Map ? data['message'] : null) ?? 'Buyurtmani yakunlab bo\'lmadi',
      );
    }
    throw ApiException(statusCode: response.statusCode, message: data['message'] ?? 'Noma\'lum xato');
  }

  Future<CurrerChatModel> sendChatMessage({required int orderId, required String message}) async {
    final uri = Uri.parse('$_baseUrl/currer/home/show/chat');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode({'order_id': orderId, 'message': message}),
    );

    final data = _parseResponseBody(response.body);

    if (response.statusCode == 200) {
      if (data is Map && data['success'] == true) {
        final raw = data['chat'] as Map<String, dynamic>;
        return CurrerChatModel(
          message: raw['message'],
          user: raw['user_id']?.toString() ?? '',
          date: raw['created_at'] ?? '',
        );
      }
      throw ApiException(statusCode: 200, message: (data is Map ? data['message'] : null) ?? 'Xabar yuborilmadi');
    }

    throw ApiException(statusCode: response.statusCode, message: data['message'] ?? 'Noma\'lum xato');
  }

  void dispose() => _client.close();
}
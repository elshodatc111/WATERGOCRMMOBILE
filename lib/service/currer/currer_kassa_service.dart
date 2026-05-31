import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:water_go/const/api_const.dart';
import 'package:water_go/models/currer/currer_balans_detal_model.dart';
import 'package:water_go/models/currer/currer_balans_history_model.dart';
import 'package:water_go/models/currer/currer_balans_model.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class CurrerKassaService {
  static String _baseUrl = ApiConst.baseUrl;
  final http.Client _client;
  final String token;

  CurrerKassaService({required this.token, http.Client? client})
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

  Future<CurrerBalansDetalModel> getBalansDetail() async {
    final uri = Uri.parse('$_baseUrl/currer/ombor');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final balans = CurrerBalansModel.fromJson(data['currer']);
      final List historyList = data['data'] ?? [];
      final history = historyList.map((e) => CurrerBalansHistoryModel.fromJson(e)).toList();
      return CurrerBalansDetalModel(balans: balans, history: history);
    }
    _handleError(response);
  }

  Future<void> kirimSuccess(int orderId) async {
    final uri = Uri.parse('$_baseUrl/currer/ombor/success');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode({'id': orderId}),
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

  Future<void> omborgaChiqim(String type, int count, String description) async {
    final uri = Uri.parse('$_baseUrl/currer/ombor/chiqim');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'type': type,
        'count': count,
        'description': description,
      }),
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

  Future<void> chiqimCancel(int orderId) async {
    final uri = Uri.parse('$_baseUrl/currer/ombor/chiqim/cancel');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode({'id': orderId}),
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


}

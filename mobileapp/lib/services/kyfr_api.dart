import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_session.dart';
import '../models/wallet_snapshot.dart';
import '../models/wallet_transaction.dart';
import 'api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class KyfrApi {
  Future<AuthSession> signup({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSession> login({required String email, required String password});

  Future<double> fetchBalance(String token);

  Future<WalletSnapshot> fetchWallet(String token);

  Future<WalletSnapshot> addMoney({
    required String token,
    required double amount,
  });

  Future<WalletSnapshot> transferMoney({
    required String token,
    required String recipientEmail,
    required double amount,
    required String note,
  });

  Future<List<WalletTransaction>> fetchTransactions(String token);

  Future<String> fetchWeeklyInsight({String? token});

  void close();
}

class HttpKyfrApi implements KyfrApi {
  HttpKyfrApi({http.Client? client, this.baseUrl = ApiConfig.defaultBaseUrl})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final String baseUrl;

  static const _timeout = Duration(seconds: 12);

  @override
  Future<AuthSession> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _postObject(
      '/auth/signup',
      body: {'name': name, 'email': email, 'password': password},
    );
    return AuthSession.fromJson(json);
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _postObject(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthSession.fromJson(json);
  }

  @override
  Future<double> fetchBalance(String token) async {
    final json = await _getObject('/balance', token: token);
    return (json['balance'] as num).toDouble();
  }

  @override
  Future<WalletSnapshot> fetchWallet(String token) async {
    final json = await _getObject('/wallet', token: token);
    return WalletSnapshot.fromJson(json);
  }

  @override
  Future<WalletSnapshot> addMoney({
    required String token,
    required double amount,
  }) async {
    final json = await _postObject(
      '/wallet/add-money',
      token: token,
      body: {'amount': amount},
    );
    return WalletSnapshot.fromJson(json);
  }

  @override
  Future<WalletSnapshot> transferMoney({
    required String token,
    required String recipientEmail,
    required double amount,
    required String note,
  }) async {
    final json = await _postObject(
      '/wallet/transfer',
      token: token,
      body: {'recipient_email': recipientEmail, 'amount': amount, 'note': note},
    );
    return WalletSnapshot.fromJson(json);
  }

  @override
  Future<List<WalletTransaction>> fetchTransactions(String token) async {
    final json = await _getList('/transactions', token: token);
    return json
        .map(
          (transaction) =>
              WalletTransaction.fromJson(transaction as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<String> fetchWeeklyInsight({String? token}) async {
    final json = await _getObject('/insights', token: token);
    final message = json['message'];
    if (message is! String || message.trim().isEmpty) {
      throw const FormatException('Insights response is missing message');
    }
    return message.trim();
  }

  Future<Map<String, dynamic>> _getObject(String path, {String? token}) async {
    final response = await _client
        .get(ApiConfig.uri(baseUrl, path), headers: _headers(token))
        .timeout(_timeout);
    return _decodeObject(response);
  }

  Future<List<dynamic>> _getList(String path, {String? token}) async {
    final response = await _client
        .get(ApiConfig.uri(baseUrl, path), headers: _headers(token))
        .timeout(_timeout);
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> _postObject(
    String path, {
    required Map<String, Object?> body,
    String? token,
  }) async {
    final response = await _client
        .post(
          ApiConfig.uri(baseUrl, path),
          headers: _headers(token),
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    return _decodeObject(response);
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = _decode(response);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('API response must be an object');
  }

  List<dynamic> _decodeList(http.Response response) {
    final decoded = _decode(response);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    throw const FormatException('API response must be a list');
  }

  dynamic _decode(http.Response response) {
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_errorMessage(decoded, response.statusCode));
    }

    return decoded;
  }

  String _errorMessage(dynamic decoded, int statusCode) {
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
      if (detail is List && detail.isNotEmpty) {
        return 'Please check the form values and try again.';
      }
    }
    return 'Request failed with status $statusCode.';
  }

  @override
  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

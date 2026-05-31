import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/realtime_transaction_event.dart';
import 'api_config.dart';

typedef TransactionEventHandler = void Function(RealtimeTransactionEvent event);

abstract class RealtimeClient {
  Future<void> connect({
    required String token,
    required TransactionEventHandler onTransaction,
  });

  Future<void> disconnect();
}

class KyfrRealtimeClient implements RealtimeClient {
  KyfrRealtimeClient({this.baseUrl = ApiConfig.defaultBaseUrl});

  final String baseUrl;

  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;

  @override
  Future<void> connect({
    required String token,
    required TransactionEventHandler onTransaction,
  }) async {
    await disconnect();

    final socket = await WebSocket.connect(
      ApiConfig.websocketUri(baseUrl, token).toString(),
    ).timeout(const Duration(seconds: 10));
    _socket = socket;
    _subscription = socket.listen((message) {
      if (message is! String) {
        return;
      }

      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic> ||
          decoded['type'] != 'TRANSACTION') {
        return;
      }

      onTransaction(RealtimeTransactionEvent.fromJson(decoded));
    });
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close();
    _socket = null;
  }
}

class NoopRealtimeClient implements RealtimeClient {
  const NoopRealtimeClient();

  @override
  Future<void> connect({
    required String token,
    required TransactionEventHandler onTransaction,
  }) async {}

  @override
  Future<void> disconnect() async {}
}

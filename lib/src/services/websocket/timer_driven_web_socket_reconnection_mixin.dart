import 'dart:async';

import 'package:web_helper_services/src/services/websocket/web_socket_service.dart';

/// Contains methods and properties to periodically check for conditions for reconnection,
/// and attempt to reconnect if so
mixin TimerDrivenWebSocketReconnectionMixin on WebSocketService {
  Timer? autoReconnectTimer;

  @override
  Future close() {
    stopReconnectionCheckTimer();
    return super.close();
  }

  /// Start a timer that periodically checks if the conditions for reconnection have been met;
  /// and begins reconnecting if so
  void startReconnectionCheckTimer() {
    stopReconnectionCheckTimer();
    autoReconnectTimer =
        Timer.periodic(Duration(milliseconds: 50), (timer) async {
      if (!await isConnectionClosed()) return;

      await closeAndReconnect();
    });
  }

  /// Stop the reconnection check timer
  void stopReconnectionCheckTimer() {
    autoReconnectTimer?.cancel();
  }

  @override
  Future<bool> initialize() async {
    try {
      return await super.initialize();
    } finally {
      startReconnectionCheckTimer();
    }
  }
}

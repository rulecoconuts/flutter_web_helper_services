import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:web_helper_services/src/models/directedMessage.dart';
import 'package:web_helper_services/src/serialization/serialization.dart';
import 'package:web_helper_services/src/services/api/api.dart';
import 'package:web_helper_services/src/services/auth/auth.dart';
import 'package:web_helper_services/src/services/auth/loginService.dart';
import 'package:web_helper_services/src/services/serverInfo.dart';
import 'package:web_helper_services/src/services/user/userService.dart';
import 'package:web_helper_services/src/services/user/userStorageService.dart';
import 'package:web_helper_services/src/services/websocket/web_socket_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Wraps [WebSocketService] API around [IOWebSocketChannel] API
mixin WebSocketChannelServiceMixin<U> on WebSocketService {
  IOWebSocketChannel? webSocketChannel;
  StreamController? webSocketStreamController;

  StreamSubscription? socketListenSubscription;

  @override
  Stream? get stream => webSocketStreamController?.stream;
  Future? closingFuture;
  Future? initializationFuture;

  /// Close and reconnect to the server
  @override
  Future closeAndReconnect() async {
    if (closingFuture != null) {
      await closingFuture;
      return;
    }

    closingFuture = Future(() async {
      try {
        // Close websocket with a reason.
        /**
         * Note that closing reason codes and messages are necessary for some
         * servers
         */
        await webSocketChannel?.sink.close(1000, "Just reconnecting");
        await webSocketChannel?.innerWebSocket
            ?.close(1000, "Just reconnecting");
        await initialize();
      } finally {
        closingFuture = null;
      }
    });
    await closingFuture;
  }

  /// Broadcast message to listeners
  @override
  Future broadcastMessage(message) async {
    webSocketStreamController?.add(message);
  }

  /// Returns true if the connection is closed
  @override
  Future<bool> isConnectionClosed() async {
    if (webSocketChannel == null || webSocketStreamController == null) {
      return true;
    }
    return webSocketChannel?.closeCode != null || closed;
  }

  /// Permanently close websocket, and all streams listening to it
  @override
  Future close() async {
    // Stop closeAndReconnect timer
    // Close websocket channel
    closed = true;
    await webSocketChannel?.sink.close(1000, "Intended closing");
    await webSocketChannel?.innerWebSocket?.close(1000, "Intended closing");
    webSocketChannel = null;
  }

  /// On websocket connection done
  void onDone() {
    onClosed();
  }

  /// On websocket connection error
  void onClosedFromError(Object object, StackTrace stackTrace) async {
    onClosed();
  }

  /// Setup web socket controller, streams, and stream controllers
  /// Reconnection strategy:
  ///   - add an onDone closure to the [webSocketChannel.stream.listen]
  ///     method call.
  ///   - onDone: cancel the stream subscription for the current stream
  ///     and call [onClosed]
  @override
  Future<bool> initialize() async {
    if (initializationFuture != null) {
      // await settingUpFuture;
      return true;
    }
    // mainCloseAndReconnectSubscription?.cancel();
    initializationFuture = Future(() async {
      var uri = Uri.parse(endpoint);
      webSocketChannel = createSocketChannel(uri);
      await authorizeConnection();

      webSocketStreamController ??= StreamController.broadcast();

      closed = false;

      // Listen for messages
      socketListenSubscription = webSocketChannel?.stream.listen((message) {
        broadcastMessage(message);
      }, onDone: onDone, onError: onClosedFromError);
    });

    try {
      await initializationFuture;
    } finally {
      initializationFuture = null;
    }

    return true;
  }

  /// Create web socket channel
  IOWebSocketChannel createSocketChannel(dynamic url,
      {Duration pingInterval = const Duration(seconds: 5)}) {
    return IOWebSocketChannel.connect(
      url,
      pingInterval: pingInterval,
    );
  }

  /// Send message
  @override
  Future<void> send<T>(T message) async {
    if (closed) await closeAndReconnect();
    webSocketChannel?.sink.add(message);
  }
}

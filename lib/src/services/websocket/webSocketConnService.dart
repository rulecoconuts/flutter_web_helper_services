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
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

mixin WebSocketConnService<U, O> on WebApiService {
  IOWebSocketChannel? webSocketChannel;
  StreamController? webSocketStreamController;
  Stream? broadcastStream;

  @override
  String get endpoint => serverInfo.url;
  Future<void> authorizeConnection();
  Stream? get stream => webSocketStreamController?.stream;
  Future closeAndReconnect() async {
    try {
      await webSocketChannel?.sink.close();
      await webSocketChannel?.innerWebSocket?.close();
      await initialize();
    } catch (e) {
      print(e);
    }
  }

  /// Setup web socket controller, streams, and stream controllers
  Future<bool> initialize() async {
    // mainCloseAndReconnectSubscription?.cancel();
    var uri = Uri.parse(endpoint);
    webSocketChannel = createSocketChannel(uri);
    await authorizeConnection();

    webSocketStreamController ??=
        StreamController.broadcast(onListen: () async {
      await webSocketStreamController!.addStream(webSocketChannel!.stream);

      // await authorizeConnection();
      // await webSocketStreamController!.done;
      // setupWebSocketConnection();
    });

    return true;
  }

  IOWebSocketChannel createSocketChannel(dynamic url,
      {Duration pingInterval = const Duration(seconds: 5)}) {
    return IOWebSocketChannel.connect(
      url,
      pingInterval: pingInterval,
    );
  }

  bool isConnectionClosed() {
    return webSocketChannel?.closeCode != null;
  }

  DirectedMessage<U> sanitizeDirectedMessage(
      DirectedMessage<U> directedMessage) {
    return directedMessage;
  }

  Future<void> send<T>(T message) async {
    if (isConnectionClosed()) await closeAndReconnect();
    webSocketChannel?.sink.add(message);
  }

  /// Send directed message to the web socket server
  Future<void> sendDirectedMessage(DirectedMessage<U> directedMessage) async {
    send<String>(
        jsonEncode(serializer.serialize<DirectedMessage<U>>(directedMessage)));
  }

  Stream<DirectedMessage<U>> listenForDirectedMessagesWithLabel(
      String label) async* {
    if (webSocketStreamController == null) await closeAndReconnect();
    await for (String messageText in webSocketStreamController!.stream) {
      var receivedMessage = deserializer
          .deserialize<DirectedMessage<U>>(json.decode(messageText));
      if (receivedMessage.label != label) continue;
      yield receivedMessage;
    }
  }
}

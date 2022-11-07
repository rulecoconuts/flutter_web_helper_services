import 'dart:async';
import 'dart:convert';

import 'package:web_helper_services/src/services/api/webApiService.dart';
import 'package:web_helper_services/web_helper_services.dart';

abstract class WebSocketService<U> with WebApiService {
  @override
  String get endpoint;

  bool get closed;
  set closed(bool closed);

  StreamSubscription? socketListenSubscription;

  Future<void> authorizeConnection();
  Stream? get stream;

  void onClosed() {
    closed = true;
    closeAndReconnect();
  }

  Future closeAndReconnect();

  /// Setup web socket controller, streams, and stream controllers
  Future<bool> initialize();

  /// Sanitize directed message to be sent
  DirectedMessage<U> sanitizeDirectedMessage(
      DirectedMessage<U> directedMessage) {
    return directedMessage;
  }

  /// Send message
  Future<void> send<T>(T message);

  /// Send directed message to the web socket server
  Future<void> sendDirectedMessage(DirectedMessage<U> directedMessage) async {
    DirectedMessage<U> sanitizedMsg = sanitizeDirectedMessage(directedMessage);
    Map<String, dynamic> map =
        serializer.serialize<DirectedMessage<U>>(sanitizedMsg);
    send<String>(json.encode(map));
  }

  /// Listen for directed messages with a label
  Stream<DirectedMessage<U>> listenForDirectedMessagesWithLabel(
      String label) async* {
    if (closed) await closeAndReconnect();
    await for (String messageText in stream!) {
      var receivedMessage = deserializer
          .deserialize<DirectedMessage<U>>(json.decode(messageText));
      if (receivedMessage.label != label) continue;
      yield receivedMessage;
    }
  }
}

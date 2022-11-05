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

class WebSocketConnService<U, O> with WebApiService {
  @override
  ServerInfo serverInfo;

  IOWebSocketChannel? webSocketChannel;
  StreamController? webSocketStreamController;
  UserStorageService userStorageService;
  Stream? broadcastStream;

  // The amount of time to wait before requesting for receipients again
  Duration receipientRequestInterval;
  Timer? receipientRequestTimer;
  Timer? autoReconnectTimer;
  StreamSubscription? mainCloseAndReconnectSubscription;
  bool _isSettingUp = false;
  bool _isClosing = false;

  @override
  GeneralDeserializer deserializer;

  @override
  GeneralSerializer serializer;

  @override
  String get endpoint => serverInfo.url;

  WebSocketConnService(this.serverInfo, this.userStorageService,
      this.deserializer, this.serializer,
      {this.webSocketStreamController,
      this.webSocketChannel,
      this.receipientRequestInterval = const Duration(seconds: 10)});

  Future<void> authorizeConnection() async {
    JwtAuth jwtAuth =
        (await userStorageService.userService.getDefaultAuth()) as JwtAuth;
    String authMessage = jwtAuth.token;
    if (authMessage.startsWith("Bearer")) {
      authMessage = authMessage.replaceFirst("Bearer ", "");
    }
    webSocketChannel!.sink.add(authMessage);
  }

  void writeChannelIncomingToBroadcast() {
    webSocketChannel!.stream.listen((event) {
      webSocketStreamController!.done;
    });
  }

  Future closeAndReconnect() async {
    if (_isClosing) return;
    _isClosing = true;
    try {
      await webSocketChannel?.sink.close();
      await webSocketChannel?.innerWebSocket?.close();
      await setupWebSocketConnection();
    } catch (e) {
      print(e);
    } finally {
      _isClosing = false;
    }
  }

  /// Setup web socket controller, streams, and stream controllers
  Future<bool> setupWebSocketConnection() async {
    // mainCloseAndReconnectSubscription?.cancel();
    if (_isSettingUp) return false;
    _isSettingUp = true;
    try {
      var uri = Uri.parse(endpoint);
      webSocketChannel =
          IOWebSocketChannel.connect(uri, pingInterval: Duration(seconds: 5));
      await authorizeConnection();
      bool isControllerNull = webSocketStreamController == null;
      if (isControllerNull) {
        broadcastStream = webSocketChannel!.stream.asBroadcastStream();
        mainCloseAndReconnectSubscription?.cancel();
        mainCloseAndReconnectSubscription = broadcastStream!.listen((event) {
          print(event);
          webSocketStreamController?.add(event);
        }, onDone: closeAndReconnect);
        webSocketStreamController = StreamController.broadcast();
        // webSocketStreamController =
        //     StreamController.broadcast(onListen: () async {
        //   await webSocketStreamController!.addStream(broadcastStream!);

        //   // await authorizeConnection();
        //   // await webSocketStreamController!.done;
        //   // setupWebSocketConnection();
        // });
      } else {
        try {
          broadcastStream = webSocketChannel!.stream.asBroadcastStream();
          mainCloseAndReconnectSubscription?.cancel();

          mainCloseAndReconnectSubscription = broadcastStream?.listen((event) {
            print(event);
            webSocketStreamController?.add(event);
          }, onDone: closeAndReconnect);

          // await webSocketStreamController!.addStream(broadcastStream!);
          // await authorizeConnection();
        } catch (e) {}
      }

      startReconnectionCheck();

      return true;
    } finally {
      _isSettingUp = false;
    }
  }

  void startReconnectionCheck() {
    autoReconnectTimer?.cancel();
    autoReconnectTimer =
        Timer.periodic(Duration(milliseconds: 50), (timer) async {
      if (!isConnectionClosed()) return;

      // await setupWebSocketConnection();
      await closeAndReconnect();
    });
  }

  /// Stop requesting for available receipients from the server
  void stopRequestingForReceipients() {
    receipientRequestTimer?.cancel();
  }

  bool isConnectionClosed() {
    return webSocketChannel?.closeCode != null;
  }

  DirectedMessage<U> sanitizeDirectedMessage(
      DirectedMessage<U> directedMessage) {
    return directedMessage;
  }

  /// Send directed message to the web socket server
  Future<void> sendDirectedMessage(DirectedMessage<U> directedMessage) async {
    if (isConnectionClosed()) await closeAndReconnect();
    webSocketChannel?.sink.add(
        jsonEncode(serializer.serialize<DirectedMessage<U>>(directedMessage)));
  }

  Stream<DirectedMessage<U>> listenForCall() async* {
    // if (webSocketStreamController == null) await setupWebSocketConnection();
    // await for (String messageText in webSocketStreamController!.stream) {
    //   var receivedMessage = DirectedMessage.fromJson(json.decode(messageText));
    //   if (receivedMessage.label != "offer") continue;
    //   yield receivedMessage;
    // }
    yield* listenForDirectedMessagesWithLabel("offer");
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

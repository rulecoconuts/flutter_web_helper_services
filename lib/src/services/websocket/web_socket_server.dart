import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketServer {
  HttpServer server;
  WebSocketServer._({required this.server});

  static Future<WebSocketServer> serve(
    Handler handler, {
    Object address = "localhost",
    int port = 8080,
    SecurityContext? securityContext,
    int? backlog,
    bool shared = false,
    String? poweredByHeader = 'Dart with package:shelf',
  }) async {
    HttpServer server = await shelf_io.serve(handler, address, port,
        securityContext: securityContext,
        backlog: backlog,
        shared: shared,
        poweredByHeader: poweredByHeader);

    return Future.value(WebSocketServer._(server: server));
  }

  static Handler createHandler(Function(WebSocketChannel) onSocketConection,
      {Duration? pingInterval}) {
    return webSocketHandler(onSocketConection, pingInterval: pingInterval);
  }

  StreamSubscription exposeStream(Function(HttpRequest) onData) {
    return server.listen(onData);
  }
}

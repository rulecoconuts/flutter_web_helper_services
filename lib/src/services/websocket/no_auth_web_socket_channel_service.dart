import 'package:web_helper_services/web_helper_services.dart';

/// A web socket service class that wraps a [WebSocketChannel] and performs no
/// authorization or authentication while connecting with a web socket server
class NoAuthWebSocketChannelService extends WebSocketService
    with WebSocketChannelServiceMixin, NoAuthWebSocketServiceMixin {
  @override
  bool closed;

  @override
  GeneralDeserializer deserializer;

  @override
  GeneralSerializer serializer;

  @override
  ServerInfo serverInfo;

  NoAuthWebSocketChannelService(
      {required this.serverInfo,
      required this.deserializer,
      required this.serializer,
      this.closed = false});

  @override
  String get endpoint => serverInfo.url;
}

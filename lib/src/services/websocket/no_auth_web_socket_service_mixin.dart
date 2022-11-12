import 'package:web_helper_services/src/services/websocket/web_socket_service.dart';

/// Contains an implementation of the [authorizeConnection] method of the
/// [WebSocketService] class that performs no authorizations
mixin NoAuthWebSocketServiceMixin on WebSocketService {
  @override
  Future<void> authorizeConnection() async {}
}

import 'package:http/src/request.dart';
import 'package:web_helper_services/web_helper_services.dart';

class WebSocketService with WebApiService {
  @override
  late GeneralDeserializer deserializer;

  @override
  late GeneralSerializer serializer;

  @override
  late ServerInfo serverInfo;

  @override
  Future<void> authorizeConnection() {
    return Future.value();
  }
  
  @override
  // TODO: implement endpoint
  String get endpoint => throw UnimplementedError();
}

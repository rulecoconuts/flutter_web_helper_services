import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_helper_services/src/services/serverInfo.dart';
import 'package:web_helper_services/src/services/websocket/webSocketService.dart';

import 'package:web_helper_services/web_helper_services.dart';

void main() {
  test("conn", () async {
    String socketURI = "ws://127.0.0.1:41467";
    Des deserializer = Des();
    Ser serializer = Ser();

    NoAuthWebSocketChannelService socketConnection =
        NoAuthWebSocketChannelService(
            serverInfo: SimpleServerInfo(socketURI),
            deserializer: deserializer,
            serializer: serializer);
    await socketConnection.initialize();
    await socketConnection.send("yo");
    dynamic future = await Future.delayed(Duration(seconds: 20));
    print("done done");
  });
}

//implement serialization and deserialization
class Des<T> with GeneralDeserializer {
  @override
  T deserialize<T>(serialized) {
    // TODO: implement deserialize
    return jsonDecode(serialized);
  }
}

class Ser<T> with GeneralSerializer {
  @override
  serialize<T>(T entity) {
    // TODO: implement serialize
    if (T is String) {
      return entity;
    }
    return jsonEncode(entity);
  }
}

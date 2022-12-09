import 'package:flutter/material.dart';
import 'package:web_helper_services/src/serialization/serialization.dart';
import 'package:web_helper_services/src/services/auth/auth.dart';
import 'package:web_helper_services/src/services/serverInfo.dart';
import 'package:http/http.dart' as http;

mixin WebApiService {
  ServerInfo get serverInfo;
  set serverInfo(ServerInfo serverInfo);

  String get endpoint;

  set deserializer(GeneralDeserializer deserializer);
  set serializer(GeneralSerializer serializer);

  GeneralDeserializer get deserializer;
  GeneralSerializer get serializer;

  /// Send request and extract response body string.
  /// Throws exception containing the response if response status code
  /// is not within the 200 - 299 range
  Future<String> sendRequest(http.Request request) async {
    var response = await request.send();
    String jsonString = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Exception(response);
    }

    return jsonString;
  }
}

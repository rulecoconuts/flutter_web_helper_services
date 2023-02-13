import 'package:flutter/material.dart';
import 'package:web_helper_services/src/serialization/serialization.dart';
import 'package:web_helper_services/src/services/auth/auth.dart';
import 'package:web_helper_services/src/services/serverInfo.dart';
import 'package:http/http.dart' as http;

abstract class WebApiService {
  ServerInfo get serverInfo;
  String get endpoint;
  GeneralDeserializer get deserializer;
  GeneralSerializer get serializer;

  /// Send request and extract response body string.
  /// Throws exception containing the response if response status code
  /// is not within the 200 - 299 range
  Future<String> sendRequest(http.Request request) async {
    var response = await request.send();
    String jsonString = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode > 299) throw response;

    return jsonString;
  }

  /// Send request and return response
  /// Throws exception containing the response if response status code
  /// is not within the 200 - 299 range
  Future<http.BaseResponse> sendRequestForResponse(http.Request request) async {
    var response = await request.send();

    if (response.statusCode < 200 || response.statusCode > 299) throw response;

    return response;
  }

  static bool has2xxResponseCode(http.BaseResponse response) {
    return response.statusCode >= 200 && response.statusCode <= 299;
  }
}

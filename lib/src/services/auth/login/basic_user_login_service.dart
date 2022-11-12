import 'dart:convert';

import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:web_helper_services/web_helper_services.dart';

abstract class BasicUserLoginService<I> extends LoginService<BasicUser<I>> {
  @override
  GeneralDeserializer deserializer;

  @override
  GeneralSerializer serializer;

  @override
  ServerInfo serverInfo;

  @override
  TokenStorage tokenStorage;

  BasicUserLoginService(
      {required this.serverInfo,
      required this.serializer,
      required this.deserializer,
      required this.tokenStorage});

  /// Convert user data to [Map] credentials by using [serializer.serialize]
  @override
  Map<String, dynamic> convertUserDataToCredentials(BasicUser<I> user) {
    return serializer.serialize<BasicUser<I>>(user) as Map<String, dynamic>;
  }

  /// Login by converting [user] to map using [convertUserDataToCredentials]
  /// method
  @override
  Future<String> login(BasicUser<I> user) async {
    Uri uri = Uri.parse(endpoint);
    Map<String, dynamic> credentials = convertUserDataToCredentials(user);
    http.Request request = http.Request("POST", uri);
    request.body = json.encode(credentials);
    return sendRequest(request);
  }
}

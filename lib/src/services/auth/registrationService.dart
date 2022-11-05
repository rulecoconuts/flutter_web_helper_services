import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:web_helper_services/src/services/api/api.dart';
import 'package:web_helper_services/src/services/auth/auth.dart';
import 'package:web_helper_services/src/services/serverInfo.dart';
import 'package:http/http.dart' as http;

mixin RegistrationService<U> on WebApiService {
  @override
  String get endpoint => serverInfo.url + "/register";

  Map<String, dynamic> convertUserDataToCredentials(U user);

  /// Register
  Future<bool> register(U user);
}

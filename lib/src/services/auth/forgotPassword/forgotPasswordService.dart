import 'dart:convert';

import 'package:web_helper_services/src/models/EmailValidationRequest.dart';
import 'package:web_helper_services/src/services/api/webApiService.dart';
import 'package:web_helper_services/src/services/auth/auth.dart';
import 'package:web_helper_services/src/services/auth/forgotPassword/OtpVerifiedPasswordChange.dart';
import 'package:web_helper_services/src/services/serverInfo.dart';
import 'package:http/http.dart' as http;

mixin ForgotPasswordService<U, O> on WebApiService {
  @override
  String get endpoint => "${serverInfo.url}/forgot-password";

  /// Verify OTP
  Future<bool> verifyOTP(EmailValidationRequest<U, O> validationRequest) async {
    String url = "$endpoint/verify";
    String jsonRequest = json.encode(
        serializer.serialize<EmailValidationRequest<U, O>>(validationRequest));

    var request = http.Request("POST", Uri.parse(url));
    request.headers["Content-Type"] = "application/json";
    request.body = jsonRequest;

    var response = await request.send();
    // if (response.statusCode != 200) {
    //   return false;
    // }
    if (response.statusCode == 403) {
      return false;
    } else if (response.statusCode != 200) {
      throw Exception(response);
    }

    return true;
  }

  Future<bool> sendOTP(U user) async {
    String url = "$endpoint/send";
    String jsonRequest = json.encode(deserializer.deserialize<U>(user));

    var request = http.Request("POST", Uri.parse(url));
    request.headers["Content-Type"] = "application/json";
    request.body = jsonRequest;

    var response = await request.send();
    if (response.statusCode != 200) {
      return false;
    }

    return true;
  }

  Future<bool> changePassword(
      OtpVerifiedPasswordChange<U, O> otpVerifiedPasswordChange) async {
    String url = "$endpoint/change";
    String jsonRequest = json.encode(serializer
        .serialize<OtpVerifiedPasswordChange<U, O>>(otpVerifiedPasswordChange));

    var request = http.Request("POST", Uri.parse(url));
    request.headers["Content-Type"] = "application/json";
    request.body = jsonRequest;

    String message = await sendRequest(request);

    return true;
  }
}

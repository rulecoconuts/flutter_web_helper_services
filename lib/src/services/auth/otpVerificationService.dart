import 'dart:convert';

import 'package:web_helper_services/src/models/EmailValidationRequest.dart';
import 'package:web_helper_services/src/services/api/api.dart';
import 'package:web_helper_services/src/services/auth/auth.dart';
import 'package:web_helper_services/src/services/serverInfo.dart';
import 'package:http/http.dart' as http;

/// Service to deal with One-Time-Password generation, and verification
mixin OTPVerificationService on WebApiService {
  @override
  String get endpoint => "${serverInfo.url}/otp";

  /// Verify OTP
  Future<bool> verifyOTP(EmailValidationRequest validationRequest) async {
    String url = "$endpoint/verify";
    String jsonRequest = json.encode(validationRequest);

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: jsonRequest);
    if (response.statusCode == 403) {
      return false;
    } else if (response.statusCode != 200) {
      throw Exception(response);
    }
    return true;
  }

  /// Send request to server to send OTP to user
  Future<bool> sendOTP(Auth auth) async {
    String url = "$endpoint";
    var request = http.Request("GET", Uri.parse(url));
    auth.addToRequest(request);
    var response = await request.send();
    if (response.statusCode != 200) {
      return false;
    }

    return true;
  }
}

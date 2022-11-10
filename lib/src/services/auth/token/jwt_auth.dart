import 'dart:async';

import 'package:web_helper_services/src/services/auth/auth_.dart';

import 'package:http/http.dart';

/// JWT Authorization Token
class JwtAuth implements Auth {
  final String token;

  JwtAuth(this.token);

  @override
  FutureOr addToMultipartRequest(MultipartRequest request) async {
    await addToBaseRequest(request);
  }

  @override
  FutureOr addToRequest(BaseRequest request) async {
    await addToBaseRequest(request);
  }

  @override
  FutureOr addToBaseRequest(BaseRequest request) async {
    request.headers["Authorization"] =
        token.startsWith("Bearer") ? token : "Bearer $token";
  }
}

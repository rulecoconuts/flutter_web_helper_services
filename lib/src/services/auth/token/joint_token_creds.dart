import 'package:http/src/base_request.dart';
import 'dart:async';

import 'package:http/src/request.dart';
import 'package:http/src/multipart_request.dart';
import 'package:web_helper_services/web_helper_services.dart';

class TokenCredentialsContext extends Auth {
  String token;
  String? refreshToken;

  TokenCredentialsContext(this.token, this.refreshToken);

  @override
  void addToMultipartRequest(MultipartRequest request) {
    addToBaseRequest(request);
  }

  @override
  void addToRequest(Request request) {
    addToBaseRequest(request);
  }

  @override
  FutureOr addToBaseRequest(BaseRequest request) {
    request.headers["Authorization"] =
        token.startsWith("Bearer") ? token : "Bearer $token";
  }
}

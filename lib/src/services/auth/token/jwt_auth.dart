import 'package:web_helper_services/src/services/auth/auth_.dart';

import 'package:http/http.dart';

/// JWT Authorization Token
class JwtAuth implements Auth {
  final String token;

  JwtAuth(this.token);

  @override
  void addToMultipartRequest(MultipartRequest request) {
    // TODO: implement addToMultipartRequest
  }

  @override
  void addToRequest(Request request) {
    request.headers["Authorization"] =
        token.startsWith("Bearer") ? token : "Bearer $token";
  }
}

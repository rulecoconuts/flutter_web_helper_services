import 'dart:async';

import 'package:http/http.dart';

/// Authorization Token
abstract class Auth {
  FutureOr addToBaseRequest(BaseRequest request);
  FutureOr addToRequest(Request request);
  FutureOr addToMultipartRequest(MultipartRequest request);
}

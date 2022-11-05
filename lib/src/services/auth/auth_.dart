import 'package:http/http.dart';

/// Authorization Token
abstract class Auth {
  void addToRequest(Request request);
  void addToMultipartRequest(MultipartRequest request);
}

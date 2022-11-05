import 'package:web_helper_services/src/services/auth/auth_.dart';

import 'package:http/http.dart';

class UsernamePasswordAuth implements Auth {
  String username;
  String password;

  String usernameLabel;
  String passwordLabel;

  UsernamePasswordAuth(this.username, this.password,
      {this.usernameLabel = "username", this.passwordLabel = "password"});

  @override
  void addToMultipartRequest(MultipartRequest request) {
    request.fields[usernameLabel] = username;
    request.fields[passwordLabel] = password;
  }

  @override
  void addToRequest(Request request,
      {Map<String, String> headers = const {
        'content-type': "application/x-www-form-urlencoded"
      }}) {
    request.headers.addAll(headers);
    request.bodyFields[usernameLabel] = username;
    request.bodyFields[passwordLabel] = password;
  }
}

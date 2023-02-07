import 'package:flutter/material.dart';
import 'package:web_helper_services/src/services/auth/loginService.dart';
import 'package:web_helper_services/web_helper_services.dart';

/// Defines [getAuth] method of [LoginService]
mixin JwtStorageGetAuthMixin<U, A> on LoginService<U, A> {
  /// Get [JwtAuth] from [TokenStorage] string
  @override
  Future<Auth> getAuth({BuildContext? context}) async {
    JwtAuth auth = JwtAuth(await tokenStorage.get() as String);
    return auth;
  }
}

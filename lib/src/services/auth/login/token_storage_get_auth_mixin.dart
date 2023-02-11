import 'package:flutter/material.dart';
import 'package:web_helper_services/src/services/auth/login/token_storage_login_service.dart';
import 'package:web_helper_services/src/services/auth/loginService.dart';
import 'package:web_helper_services/src/services/auth/token/joint_token_creds.dart';
import 'package:web_helper_services/web_helper_services.dart';

/// Defines [getAuth] method of [LoginService]
mixin TokenStorageGetAuthMixin<U> on TokenStorageLoginService<U> {
  /// Get [TokenCredentialsContext] from [TokenStorage] string
  @override
  Future<TokenCredentialsContext> getAuth({BuildContext? context}) async {
    TokenCredentialsContext auth = TokenCredentialsContext(
        await tokenStorage.get() as String,
        await tokenStorage.getRefreshToken() as String?);
    return auth;
  }
}

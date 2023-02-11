import 'dart:convert';

import 'package:web_helper_services/src/services/auth/login/token_storage_login_service.dart';
import 'package:web_helper_services/src/services/auth/token/joint_token_creds.dart';

/// Mixin that defines token refresh strategy for [TokenStorageLoginService]
mixin TokenRefreshMixin<U> on TokenStorageLoginService<U> {
  /// Fetch a new token using the current credentials context.
  /// This method is in this class because we assume that tokens will naturally
  /// require some method of refreshing.
  ///
  /// This implementation simply converts the [context] to a json string
  Future<String> serializeCredentialsContextForRefresh(
      TokenCredentialsContext context) async {
    Map<String, dynamic> credentials = {
      "accessToken": context.token.replaceAll("Bearer ", ""),
      "refreshToken": context.refreshToken,
    };

    return json.encode(credentials);
  }
}

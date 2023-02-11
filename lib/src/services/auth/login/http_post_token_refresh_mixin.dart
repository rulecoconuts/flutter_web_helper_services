import 'dart:convert';

import 'package:web_helper_services/src/services/auth/login/token_refresh_mixin.dart';
import 'package:web_helper_services/src/services/auth/token/joint_token_creds.dart';
import 'package:http/http.dart' as http;
import 'package:web_helper_services/src/services/user/user.dart';

/// Mixin that defines a token refresh strategy that is centered around sending
/// a [TokenCredentialsContext] object to the server and receiving a
/// new [TokenCredentialsContext] object
mixin HttpPostTokenRefreshMixin<U> on TokenRefreshMixin<U> {
  /// Get the URL to send the [context] to for refreshing
  Future<String> getRefreshUrl(TokenCredentialsContext context) async {
    return "${serverInfo.url}/refreshToken";
  }

  /// Process http response into a new [TokenCredentialsContext]
  Future<TokenCredentialsContext> getContextFromRefreshResponse(
      http.BaseResponse response) async {
    String newToken = response.headers["authorization"] as String;
    String newRefreshToken = response.headers["RefreshToken"] as String;

    return TokenCredentialsContext(newToken, newRefreshToken);
  }

  /// Fetch a new token by posting the [context] to some server defined by
  /// [getRefreshUrl].
  /// The response is processed into a [TokenCredentialsContext] using
  /// [getContextFromRefreshResponse].
  ///
  /// If the server responds with a status code that is not in the 2xx range,
  /// the repsonse will be thrown.
  @override
  Future<TokenCredentialsContext> fetchNewToken(
      TokenCredentialsContext context) async {
    String url = await getRefreshUrl(context);

    var body = await serializeCredentialsContextForRefresh(context);

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);

    if (!has2xxResponseCode(response)) throw response;

    return await getContextFromRefreshResponse(response);
  }
}

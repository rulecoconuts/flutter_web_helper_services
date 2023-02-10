import 'package:web_helper_services/src/services/auth/login/http_post_token_refresh_mixin.dart';
import 'package:web_helper_services/src/services/auth/login/token_refresh_mixin.dart';
import 'package:web_helper_services/src/services/auth/login/token_storage_login_service.dart';
import 'package:web_helper_services/src/services/auth/token/joint_token_creds.dart';
import 'package:web_helper_services/web_helper_services.dart';
import 'package:http/http.dart' as http;

/// A generalized basic login service that is centered around token storage.
/// It takes [BasicUser<I>] as login input and [TokenCredentialsContext] as
/// returned authentication.
///
/// The refresh strategy used is [HttpPostTokenRefreshMixin].
///
/// Serializer and deserializer are currently just fields for the user to set.
/// However, we hope to replace these with just getters from a mixin that return
/// default implementations of some all-purpose serializer and deserializer
class TokenStorageBasicUserLoginService<I>
    extends TokenStorageLoginService<BasicUser<I>>
    with
        TokenStorageGetAuthMixin<BasicUser<I>>,
        TokenRefreshMixin<BasicUser<I>>,
        HttpPostTokenRefreshMixin<BasicUser<I>> {
  @override
  GeneralDeserializer deserializer;

  @override
  GeneralSerializer serializer;

  @override
  ServerInfo serverInfo;

  @override
  TokenStorage tokenStorage;

  String subpath;
  TokenStorageBasicUserLoginService(
      {required this.subpath,
      required this.serializer,
      required this.deserializer,
      required this.serverInfo,
      required this.tokenStorage});
  @override
  String get endpoint => "${serverInfo.url}/$subpath";

  /// Convert user data to [Map] credentials by using [serializer.serialize]
  @override
  String serializeUserInfoForLogin(BasicUser<I> user) {
    return serializer.serialize<BasicUser<I>>(user) as String;
  }

  /// Login by converting [user] to map using [serializeUserInfoForLogin]
  /// method
  @override
  Future<TokenCredentialsContext> login(BasicUser<I> user) async {
    Uri uri = Uri.parse(endpoint);
    http.Request request = http.Request("POST", uri);
    request.body = serializeUserInfoForLogin(user);
    var response = await request.send();
    if (!has2xxResponseCode(response)) throw response;

    return await fetchAuthFromLoginResponse(response);
  }

  /// Fetch a new token using the current credentials context.
  @override
  Future<TokenCredentialsContext> fetchAuthFromLoginResponse(
      http.BaseResponse response) async {
    String token = response.headers["authorization"] as String;
    String? refreshToken = response.headers["RefreshToken"];

    return TokenCredentialsContext(token, refreshToken);
  }
}

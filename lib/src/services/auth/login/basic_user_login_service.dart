import 'package:http/http.dart' as http;
import 'package:web_helper_services/src/services/auth/login/token_storage_login_service.dart';
import 'package:web_helper_services/src/services/auth/token/joint_token_creds.dart';
import 'package:web_helper_services/web_helper_services.dart';

abstract class BasicUserLoginService<I>
    extends TokenStorageLoginService<BasicUser<I>, TokenCredentialsContext> {
  @override
  GeneralDeserializer deserializer;

  @override
  GeneralSerializer serializer;

  @override
  ServerInfo serverInfo;

  @override
  TokenStorage tokenStorage;

  BasicUserLoginService(
      {required this.serverInfo,
      required this.serializer,
      required this.deserializer,
      required this.tokenStorage});

  /// Convert user data to [Map] credentials by using [serializer.serialize]
  @override
  String convertUserDataToCredentials(BasicUser<I> user) {
    return serializer.serialize<BasicUser<I>>(user) as String;
  }

  /// Login by converting [user] to map using [convertUserDataToCredentials]
  /// method
  @override
  Future<TokenCredentialsContext> login(BasicUser<I> user) async {
    Uri uri = Uri.parse(endpoint);
    http.Request request = http.Request("POST", uri);
    request.body = convertUserDataToCredentials(user);
    var response = await request.send();
    if (!hasGoodResponseCode(response)) throw Exception(response);
    String token = response.headers["authorization"] as String;
    String? refreshToken = response.headers["RefreshToken"];

    return TokenCredentialsContext(token, refreshToken);
  }
}

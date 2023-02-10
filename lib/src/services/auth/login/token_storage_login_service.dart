import 'package:web_helper_services/src/services/auth/loginService.dart';
import 'package:web_helper_services/src/services/auth/token/joint_token_creds.dart';
import 'package:web_helper_services/src/storage/storage.dart';
import 'package:web_helper_services/web_helper_services.dart';

/// Login Service centered around receiving and storing tokens.
abstract class TokenStorageLoginService<U>
    extends LoginService<U, TokenCredentialsContext> {
  TokenStorage get tokenStorage;

  /// Fetch a new token using the current credentials context.
  /// This method is in this class because we assume that tokens will naturally
  /// require some method of refreshing.
  Future<TokenCredentialsContext> fetchNewToken(
      TokenCredentialsContext context);
}

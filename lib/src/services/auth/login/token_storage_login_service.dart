import 'package:web_helper_services/src/services/auth/loginService.dart';
import 'package:web_helper_services/src/storage/storage.dart';

abstract class TokenStorageLoginService<U, A> extends LoginService<U, A> {
  TokenStorage get tokenStorage;
}

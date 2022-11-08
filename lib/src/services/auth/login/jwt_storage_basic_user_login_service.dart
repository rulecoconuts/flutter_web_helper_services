import 'package:web_helper_services/src/services/auth/login/basic_user_login_service.dart';
import 'package:web_helper_services/src/services/auth/login/jwt_storage_get_auth.dart';
import 'package:web_helper_services/web_helper_services.dart';

/// A login service implementation that contains login functionality from
/// the [BasicUserLoginService] class, and authentication retrieval
/// functionality from [JwtStorageGetAuthMixin]
class JwtStorageBasicUserLoginService<I> extends BasicUserLoginService<I>
    with JwtStorageGetAuthMixin<BasicUser<I>> {
  String subpath;
  JwtStorageBasicUserLoginService(
      {required ServerInfo serverInfo,
      required GeneralSerializer serializer,
      required GeneralDeserializer deserializer,
      required TokenStorage tokenStorage,
      required this.subpath})
      : super(
            serializer: serializer,
            deserializer: deserializer,
            serverInfo: serverInfo,
            tokenStorage: tokenStorage);
  @override
  String get endpoint => "${serverInfo.url}/$subpath";
}

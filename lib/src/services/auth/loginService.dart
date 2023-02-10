import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:web_helper_services/src/services/api/api.dart';
import 'package:web_helper_services/src/services/auth/auth.dart';
import 'package:web_helper_services/src/services/auth/token/tokenExceptions.dart';
import 'package:web_helper_services/src/services/serverInfo.dart';
import 'package:http/http.dart' as http;
import 'package:web_helper_services/src/storage/tokenStorage.dart';

/// Base abstract LoginService.
/// [U] is the type of the user information
/// [A] is the type of the authentication that should be returned from a call to
/// [LoginService.login]
abstract class LoginService<U, A> with WebApiService {
  /// Convert user info to some string that can be easily sent to an
  /// authentication server somewhere
  String serializeUserInfoForLogin(U user);

  ///
  /// Login(Get a token from the API)
  ///
  Future<A> login(U user);

  /// Generate Auth object based on the app-wide strategy
  /// This method will only return an Auth object if generating it is successful.
  /// If a token has not been stored, a [TokenDoesNotExistException] will be thrown.
  /// Likewise, if the stored token is expired and cannot be renewed; two things can
  /// occur:
  ///   - If the [context] argument is not null; navigation to the login page
  ///     defined by 'login' will be attempted.
  ///   - else; an [UnableToRenewTokenException] will be thrown
  Future<A> getAuth({BuildContext? context});

  /// Process http response into an authentication object
  Future<A> fetchAuthFromLoginResponse(http.BaseResponse response);
}

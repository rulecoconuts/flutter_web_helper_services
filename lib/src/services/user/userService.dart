import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_helper_services/src/serialization/serialization.dart';
import 'package:web_helper_services/src/services/api/api.dart';
import 'package:web_helper_services/src/services/auth/auth.dart';
import 'package:web_helper_services/src/services/auth/loginService.dart';
import 'package:web_helper_services/src/services/serverInfo.dart';
import 'package:http/http.dart' as http;

mixin UserService<U> on CRUDService<U> {
  @override
  String get endpoint => serverInfo.url + "/users";

  @override
  String getEntityURL(U entity);

  @override
  String get resourceRel => "users";

  @override
  String get searchPath => "userSearch";

  /// Get update user information from the server
  Future<U> getLatestUserInfo(U user,
      {Auth? auth, BuildContext? context, bool expanded = false}) async {
    String url = getEntityURL(user);
    if (expanded) {
      // Completely expand the entity relationships into objects
      url += "?projection=expanded";
    }
    return await getFromUrl(url, auth: auth, context: context);
  }
}

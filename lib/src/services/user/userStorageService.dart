import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:storage_helper_services/storage_helper_services.dart';
import 'package:web_helper_services/src/services/auth/auth.dart';
import 'package:web_helper_services/src/services/auth/loginService.dart';
import 'package:web_helper_services/src/services/user/userService.dart';
import 'package:web_helper_services/src/storage/tokenStorage.dart';

class UserStorageService {
  final UserService userService;
  final LoginService loginService;

  final String currentUserKey;
  ObjectStorage objectStorage;

  UserStorageService(
      {required this.userService,
      required this.loginService,
      required this.objectStorage,
      this.currentUserKey = "current-user"});
}

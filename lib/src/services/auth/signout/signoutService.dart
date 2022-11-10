import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_helper_services/src/services/user/userStorageService.dart';

abstract class SignoutService {
  FutureOr<dynamic> signout({BuildContext? context});
}

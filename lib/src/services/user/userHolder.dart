import 'package:flutter/foundation.dart';

class UserHolder<U> extends ValueNotifier<U> {
  UserHolder(U user) : super(user);
}

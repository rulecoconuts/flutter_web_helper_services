import 'package:flutter/foundation.dart';

class UserHolder<U> with ChangeNotifier {
  U? _user;
  UserHolder();

  /// Notifies listeners when the user changes
  set user(U? user) {
    bool callUserChanged = user != _user;
    _user = user;
    if (callUserChanged) {
      notifyListeners();
    }
  }

  U? get user => _user;
}

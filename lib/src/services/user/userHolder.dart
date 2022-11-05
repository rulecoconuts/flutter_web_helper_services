class UserHolder<U> {
  U? _user;
  Function(U? user)? onUserChanged;
  UserHolder();

  set user(U? user) {
    bool callUserChanged = user != _user;
    _user = user;
    if (callUserChanged) {
      onUserChanged?.call(_user);
    }
  }

  U? get user => _user;
}

import 'dart:async';

/// Token storage
/// where [T] is the token type
abstract class TokenStorage<T> {
  String get key;
  String get refreshKey;

  FutureOr store(T token);
  FutureOr get();
  FutureOr delete();
  Future<bool> contains();
  FutureOr<Map<String, dynamic>> payload();
  FutureOr<bool> isExpired();
  FutureOr storeRefreshToken(String refreshToken);
  FutureOr getRefreshToken();

  /// Returns true if the stored token is close to expiry.
  FutureOr<bool> isCloseToExpiry();
}

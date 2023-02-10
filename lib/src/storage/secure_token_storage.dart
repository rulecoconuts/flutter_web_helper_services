import 'dart:async';
import 'dart:convert';

import 'package:storage_helper_services/storage_helper_services.dart';
import 'package:web_helper_services/src/storage/tokenStorage.dart';

/// Secure token storage
/// Wrapped around [SecureObjectStorage] from {flutter_secure_storage} package
///
/// Stores a single token under a key
class SecureTokenStorage<T> extends TokenStorage<T> {
  SecureObjectStorage storage;
  Duration closeToExpiry;

  @override
  String key;

  @override
  String get refreshKey => "$key-refresh-token";

  SecureTokenStorage(this.key, this.storage,
      {this.closeToExpiry = const Duration(seconds: 30)});

  /// Get the stored token
  @override
  FutureOr<String?> get() async {
    return await storage.get(key);
  }

  /// Get payload of token as a [Map]
  Future<Map<String, dynamic>> payload() async {
    return parseJwt((await get())!);
  }

  /// Parse JWT string payload into a [Map]
  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  /// Store a string token
  @override
  FutureOr store(T token) async {
    return await storage.store(key, token);
  }

  @override
  FutureOr delete() async {
    await storage.delete(key);
    await storage.delete(refreshKey);
  }

  @override
  Future<bool> contains() async {
    return await storage.contains(key);
  }

  @override
  FutureOr<bool> isExpired() async {
    var payload = await this.payload();
    int milliseconds = int.parse(payload["exp"]);
    DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateTime.now().compareTo(expiryDate) > 0;
  }

  /// Returns true if the stored token is close to expiry.
  /// "Close to expiry" is defined by the closeToExpiry property
  @override
  FutureOr<bool> isCloseToExpiry() async {
    var payload = await this.payload();
    int milliseconds = payload["exp"] as int;
    DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateTime.now().difference(expiryDate).compareTo(closeToExpiry) <= 0;
  }

  @override
  FutureOr getRefreshToken() async {
    return await storage.get(refreshKey);
  }

  @override
  FutureOr storeRefreshToken(String refreshToken) async {
    return await storage.store(refreshKey, refreshToken);
  }
}

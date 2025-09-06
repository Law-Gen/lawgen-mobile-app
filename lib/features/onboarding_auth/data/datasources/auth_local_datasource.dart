// features/onboarding_auth/data/datasources/auth_local_datasource.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDatasource {
  Future<void> cacheToken(String accessToken, String refreshToken);
  Future<Map<String, String?>> getTokens();
  Future<void> clearTokens();

  Future<void> cacheUserInfo(String userId, String email, String name);
  Future<Map<String, String?>> getUserInfo();
  Future<void> clearUserInfo();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final FlutterSecureStorage secureStorage;

  // ✅ FIX: Keys are now public static constants. This is the single source of truth.
  static const String accessTokenKey = 'ACCESS_TOKEN';
  static const String refreshTokenKey = 'REFRESH_TOKEN';

  // These can remain private as they are only used within this file.
  static const _userIdKey = 'USER_ID';
  static const _userEmailKey = 'USER_EMAIL';
  static const _userNameKey = 'USER_NAME';

  AuthLocalDatasourceImpl({required this.secureStorage});

  // ---------- TOKEN METHODS ----------
  @override
  Future<void> cacheToken(String accessToken, String refreshToken) async {
    // Now using the public constants to write data.
    await secureStorage.write(key: accessTokenKey, value: accessToken);
    await secureStorage.write(key: refreshTokenKey, value: refreshToken);
  }

  @override
  Future<Map<String, String?>> getTokens() async {
    final accessToken = await secureStorage.read(key: accessTokenKey);
    final refreshToken = await secureStorage.read(key: refreshTokenKey);
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: accessTokenKey);
    await secureStorage.delete(key: refreshTokenKey);
  }

  // ---------- USER INFO METHODS (Unchanged) ----------
  @override
  Future<void> cacheUserInfo(String userId, String email, String name) async {
    await secureStorage.write(key: _userIdKey, value: userId);
    await secureStorage.write(key: _userEmailKey, value: email);
    await secureStorage.write(key: _userNameKey, value: name);
  }

  @override
  Future<Map<String, String?>> getUserInfo() async {
    final userId = await secureStorage.read(key: _userIdKey);
    final email = await secureStorage.read(key: _userEmailKey);
    final name = await secureStorage.read(key: _userNameKey);

    return {'userId': userId, 'email': email, 'name': name};
  }

  @override
  Future<void> clearUserInfo() async {
    await secureStorage.delete(key: _userIdKey);
    await secureStorage.delete(key: _userEmailKey);
    await secureStorage.delete(key: _userNameKey);
  }
}

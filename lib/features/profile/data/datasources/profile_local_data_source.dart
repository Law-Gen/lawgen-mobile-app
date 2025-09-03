import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ProfileLocalDataSource {
  Future<void> cacheToken(String accessToken, String refreshToken);
  Future<Map<String, String?>> getTokens();
  Future<void> clearTokens();

  Future<void> cacheUserInfo(String userId, String email, String name);
  Future<Map<String, String?>> getUserInfo();
  Future<void> clearUserInfo();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final FlutterSecureStorage secureStorage;

  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';
  static const _userIdKey = 'USER_ID';
  static const _userEmailKey = 'USER_EMAIL';
  static const _userNameKey = 'USER_NAME';

  ProfileLocalDataSourceImpl({required this.secureStorage});
  @override
  Future<void> cacheToken(String accessToken, String refreshToken) async {
    await secureStorage.write(key: _accessTokenKey, value: accessToken);
    await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<Map<String, String?>> getTokens() async {
    final accessToken = await secureStorage.read(key: _accessTokenKey);
    final refreshToken = await secureStorage.read(key: _refreshTokenKey);
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
  }

  // ---------- USER ----------
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

    return {
      'userId': userId,
      'email': email,
      'name': name,
    };
  }

  @override
  Future<void> clearUserInfo() async {
    await secureStorage.delete(key: _userIdKey);
    await secureStorage.delete(key: _userEmailKey);
    await secureStorage.delete(key: _userNameKey);
  }
}



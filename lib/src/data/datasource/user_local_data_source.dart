import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloc_clean_architecture/src/data/models/user_model.dart';

abstract class UserLocalDataSource {
  Future<List<UserModel>> getCachedUsers();
  Future<void> cacheUsers(List<UserModel> users);
  Future<void> clearCache();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  static const String _usersCacheKey = 'cached_users';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const int _cacheExpiryHours = 24;

  @override
  Future<List<UserModel>> getCachedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUsersJson = prefs.getString(_usersCacheKey);
    final cacheTimestamp = prefs.getInt(_cacheTimestampKey);

    if (cachedUsersJson != null && cacheTimestamp != null) {
      // Check if cache is still valid
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = now - cacheTimestamp;
      final cacheExpiryMs = _cacheExpiryHours * 60 * 60 * 1000;

      if (cacheAge < cacheExpiryMs) {
        final List<dynamic> usersJson =
            json.decode(cachedUsersJson) as List<dynamic>;
        return usersJson
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((user) => user.toJson()).toList();

    await prefs.setString(_usersCacheKey, json.encode(usersJson));
    await prefs.setInt(
      _cacheTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersCacheKey);
    await prefs.remove(_cacheTimestampKey);
  }
}

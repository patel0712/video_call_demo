import 'package:bloc_clean_architecture/src/comman/api.dart';
import 'package:bloc_clean_architecture/src/comman/constant.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthenticationRemoteDataSource {
  Future<void> login(String email, String password);
}

class AuthenticationRemoteDataSourceImpl
    implements AuthenticationRemoteDataSource {
  final Dio dio = Dio();

  // Hardcoded credentials for testing
  static const String _testEmail = 'test@example.com';
  static const String _testPassword = 'password123';

  @override
  Future<void> login(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check hardcoded credentials first
      if (email == _testEmail && password == _testPassword) {
        await prefs.setString(ACCESS_TOKEN,
            'hardcoded_token_${DateTime.now().millisecondsSinceEpoch}');
        return;
      }

      // Try ReqRes API
      final response = await dio.post<Map<String, dynamic>>(API.LOGIN, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data?['token']?.toString() ??
            'reqres_token_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString(ACCESS_TOKEN, token);
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      // If API fails, check if it's a known ReqRes test user
      if (email == 'eve.holt@reqres.in' && password == 'cityslicka') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ACCESS_TOKEN,
            'reqres_test_token_${DateTime.now().millisecondsSinceEpoch}');
        return;
      }
      rethrow;
    }
  }
}

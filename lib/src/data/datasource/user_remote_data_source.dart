import 'package:bloc_clean_architecture/src/comman/api.dart';
import 'package:bloc_clean_architecture/src/data/models/user_model.dart';
import 'package:dio/dio.dart';

abstract class UserRemoteDataSource {
  Future<UsersResponse> getUsers(int page);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UsersResponse> getUsers(int page) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '${ApiConstants.baseUrl}/users',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      print("response =====> ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        // JSONPlaceholder returns a direct array of users, not wrapped in an object
        final List<UserModel> users = response.data!
            .map((userJson) =>
                UserModel.fromJson(userJson as Map<String, dynamic>))
            .toList();

        return UsersResponse(data: users);
      }

      // Surface proper error status codes
      final code = response.statusCode ?? 0;
      throw Exception('Failed to load users (status: $code)');
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
}

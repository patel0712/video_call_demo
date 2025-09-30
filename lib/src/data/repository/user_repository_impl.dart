import 'package:bloc_clean_architecture/src/comman/failure.dart';
import 'package:bloc_clean_architecture/src/data/datasource/user_local_data_source.dart';
import 'package:bloc_clean_architecture/src/data/datasource/user_remote_data_source.dart';
import 'package:bloc_clean_architecture/src/data/models/user_model.dart';
import 'package:bloc_clean_architecture/src/domain/entities/user_entity.dart';
import 'package:bloc_clean_architecture/src/domain/repositories/user_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );

  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;
  final Connectivity _connectivity;

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers(int page) async {
    try {
      // Check connectivity
      final connectivityResults = await _connectivity.checkConnectivity();

      if (connectivityResults == ConnectivityResult.none) {
        // No internet connection, try to get cached data
        final cachedUsers = await _localDataSource.getCachedUsers();
        if (cachedUsers.isNotEmpty) {
          final userEntities = cachedUsers
              .map(
                (user) => UserEntity(
                  id: user.id,
                  email: user.email,
                  firstName: user.firstName,
                  lastName: user.lastName,
                  avatar: user.avatar,
                ),
              )
              .toList();
          return Right(userEntities);
        } else {
          return const Left(ConnectionFailure('No internet connection'));
        }
      }

      // Internet connection available, fetch from API
      final usersResponse = await _remoteDataSource.getUsers(page);
      final userEntities = usersResponse.data
          .map(
            (user) => UserEntity(
              id: user.id,
              email: user.email,
              firstName: user.firstName,
              lastName: user.lastName,
              avatar: user.avatar,
            ),
          )
          .toList();

      // Cache strategy:
      // - If first page, overwrite cache
      // - If subsequent pages, merge with existing cached users (dedupe by id)
      if (page <= 1) {
        await _localDataSource.cacheUsers(usersResponse.data);
      } else {
        try {
          final cached = await _localDataSource.getCachedUsers();
          final Map<int, UserModel> idToUser = {
            for (final u in cached) u.id: u,
          };
          for (final u in usersResponse.data) {
            idToUser[u.id] = u;
          }
          await _localDataSource.cacheUsers(idToUser.values.toList());
        } catch (_) {
          // If merging fails, fall back to caching the latest page only
          await _localDataSource.cacheUsers(usersResponse.data);
        }
      }

      return Right(userEntities);
    } catch (e) {
      // If API fails, try to return cached data
      try {
        final cachedUsers = await _localDataSource.getCachedUsers();
        if (cachedUsers.isNotEmpty) {
          final userEntities = cachedUsers
              .map(
                (user) => UserEntity(
                  id: user.id,
                  email: user.email,
                  firstName: user.firstName,
                  lastName: user.lastName,
                  avatar: user.avatar,
                ),
              )
              .toList();
          return Right(userEntities);
        }
      } catch (_) {
        // Ignore cache errors
      }

      return Left(ServerFailure(e.toString()));
    }
  }
}

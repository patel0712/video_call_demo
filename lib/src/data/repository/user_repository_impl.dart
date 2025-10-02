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
      // Always try to fetch from API first
      final usersResponse = await _remoteDataSource.getUsers(page);
      final userEntities = usersResponse.data
          .map(
            (user) => UserEntity(
              id: user.id,
              name: user.name,
              username: user.username,
              email: user.email,
              phone: user.phone,
              website: user.website,
              address: AddressEntity(
                street: user.address.street,
                suite: user.address.suite,
                city: user.address.city,
                zipcode: user.address.zipcode,
                geo: GeoEntity(
                  lat: user.address.geo.lat,
                  lng: user.address.geo.lng,
                ),
              ),
              company: CompanyEntity(
                name: user.company.name,
                catchPhrase: user.company.catchPhrase,
                bs: user.company.bs,
              ),
            ),
          )
          .toList();

      // Cache the fresh data
      await _localDataSource.cacheUsers(usersResponse.data);

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
                  name: user.name,
                  username: user.username,
                  email: user.email,
                  phone: user.phone,
                  website: user.website,
                  address: AddressEntity(
                    street: user.address.street,
                    suite: user.address.suite,
                    city: user.address.city,
                    zipcode: user.address.zipcode,
                    geo: GeoEntity(
                      lat: user.address.geo.lat,
                      lng: user.address.geo.lng,
                    ),
                  ),
                  company: CompanyEntity(
                    name: user.company.name,
                    catchPhrase: user.company.catchPhrase,
                    bs: user.company.bs,
                  ),
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

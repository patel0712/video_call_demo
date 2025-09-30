import 'package:dartz/dartz.dart';
import 'package:bloc_clean_architecture/src/comman/failure.dart';
import 'package:bloc_clean_architecture/src/domain/entities/user_entity.dart';
import 'package:bloc_clean_architecture/src/domain/repositories/user_repository.dart';

class GetUsers {
  GetUsers(this._userRepository);

  final UserRepository _userRepository;

  Future<Either<Failure, List<UserEntity>>> call(int page) async {
    return _userRepository.getUsers(page);
  }

  Future<Either<Failure, List<UserEntity>>> execute(int page) async {
    return call(page);
  }
}

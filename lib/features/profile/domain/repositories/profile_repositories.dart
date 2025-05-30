import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/profile/domain/entities/profile_entities.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntities>> getUserProfile();
  Future<Either<Failure, ProfileEntities>> updateProfile(ProfileEntities request);
  Future<Either<Failure, void>> logout();
}
import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/exception.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/platform/platform_info.dart';
import 'package:clinic/features/profile/data/datasource/profile_local_data_source.dart';
import 'package:clinic/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:clinic/features/profile/data/model/profile_model.dart';
import 'package:clinic/features/profile/domain/entities/profile_entities.dart';
import 'package:clinic/features/profile/domain/repositories/profile_repositories.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final PlatformInfo platformInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.platformInfo,
  });

  @override
  Future<Either<Failure, ProfileEntities>> getUserProfile() async {
    if (await platformInfo.isNetworkAvailable()) {
      try {
        final remoteUser = await remoteDataSource.getUserProfile();
        await localDataSource.cacheUserProfile(remoteUser);
        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final localUser = await localDataSource.getCachedUserProfile();
        return Right(localUser);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, ProfileEntities>> updateProfile(
      ProfileEntities request) async {
    if (await platformInfo.isNetworkAvailable()) {
      try {
        final updateModel = ProfileModel(
          id: request.id,
          username: request.username,
          email: request.email,
          verified: request.verified,
          agreedToTerms: request.agreedToTerms,
          biometricEnabled: request.biometricEnabled,
          userType: request.userType,
          name: request.name,
          fullName: request.fullName,
          avatar: request.avatar,
          dateOfBirth: request.dateOfBirth,
          gender: request.gender,
          isAvailable: request.isAvailable,
          medicalLicense: request.medicalLicense,
          phoneNumber: request.phoneNumber,
          specialization: request.specialization,
        );
        final updatedProfile =
            await remoteDataSource.updateProfile(updateModel);

        // Yangilangan ma'lumotni cache'ga saqlash
        await localDataSource.cacheUserProfile(updatedProfile);

        return Right(updatedProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnexpectedFailure(message: ' '));
      }
    } else {
      try {
        final localUser = await localDataSource.getCachedUserProfile();
        return Right(localUser);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await platformInfo.isNetworkAvailable()) {
        try {
          await remoteDataSource.logout();
        } catch (e) {
          // Даже если удаленный выход не удался, мы все равно очищаем локальные данные
        }
      }

      await localDataSource.clearUserData();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}

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
        // Server xatosi bo'lsa, cache'dan olishga harakat qilamiz
        try {
          final localUser = await localDataSource.getCachedUserProfile();
          return Right(localUser);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        return Left(
            UnexpectedFailure(message: 'Неожиданная ошибка: ${e.toString()}'));
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
        // Entity ni Model ga aylantirish
        final ProfileModel updateModel;
        if (request is ProfileModel) {
          updateModel = request;
        } else {
          updateModel = ProfileModel.fromEntity(request);
        }

        // Remote update
        final updatedProfile =
            await remoteDataSource.updateProfile(updateModel);

        // Cache'ni yangilash
        await localDataSource.cacheUserProfile(updatedProfile);

        return Right(updatedProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnexpectedFailure(
          message: 'Ошибка при обновлении профиля: ${e.toString()}',
        ));
      }
    } else {
      // Internet yo'q bo'lsa, faqat cache'ni yangilaymiz
      try {
        final ProfileModel updateModel;
        if (request is ProfileModel) {
          updateModel = request;
        } else {
          updateModel = ProfileModel.fromEntity(request);
        }

        await localDataSource.cacheUserProfile(updateModel);
        return Right(updateModel);
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
          // Remote logout muvaffaqiyatsiz bo'lsa ham, local ma'lumotlarni tozalaymiz
        }
      }

      await localDataSource.clearUserData();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Ошибка при выходе из системы: ${e.toString()}',
      ));
    }
  }
}

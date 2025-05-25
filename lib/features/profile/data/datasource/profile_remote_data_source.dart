import 'package:clinic/core/error/exception.dart';
import 'package:clinic/core/local/local_storage_service.dart';
import 'package:clinic/core/local/storage_keys.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/core/di/injection_container.dart';
import 'package:clinic/features/profile/data/model/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getUserProfile();
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final NetworkManager networkManager;

  ProfileRemoteDataSourceImpl({required this.networkManager});

  @override
  Future<ProfileModel> getUserProfile() async {
    try {
      final data = await networkManager.fetchData(
        url: 'user/',
      );
      return ProfileModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Не удалось загрузить данные профиля');
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken =
        sl<LocalStorageService>().getString(StorageKeys.refreshToken);
    try {
      await networkManager.postData(url: 'logout/', data: {
        "refresh": refreshToken,
      });
    } catch (e) {
      throw ServerException(message: 'Ошибка при выходе из аккаунта');
    }
  }
}

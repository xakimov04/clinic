import 'dart:convert';

import 'package:clinic/core/error/exception.dart';
import 'package:clinic/core/local/local_storage_service.dart';
import 'package:clinic/core/local/storage_keys.dart';
import 'package:clinic/features/client/profile/data/model/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel> getCachedUserProfile();
  Future<void> cacheUserProfile(ProfileModel userModel);
  Future<void> clearUserData();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final LocalStorageService localStorageService;

  ProfileLocalDataSourceImpl({required this.localStorageService});

  @override
  Future<ProfileModel> getCachedUserProfile() async {
    try {
      final userString = await localStorageService.getString(StorageKeys.userProfile);
      if (userString == null) {
        throw CacheException(message: 'Нет сохраненных данных пользователя');
      }
      return ProfileModel.fromJson(
        Map<String, dynamic>.from(
          const JsonDecoder().convert(userString),
        ),
      );
    } catch (e) {
      throw CacheException(message: 'Ошибка при получении данных профиля');
    }
  }

  @override
  Future<void> cacheUserProfile(ProfileModel userModel) async {
    try {
      await localStorageService.setString(
        StorageKeys.userProfile,
        const JsonEncoder().convert(userModel.toJson()),
      );
    } catch (e) {
      throw CacheException(message: 'Ошибка при сохранении данных профиля');
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await localStorageService.remove(StorageKeys.userProfile);
      await localStorageService.remove(StorageKeys.accesToken);
      await localStorageService.remove(StorageKeys.refreshToken);
      await localStorageService.setBool(StorageKeys.isLoggedIn, false);
    } catch (e) {
      throw CacheException(message: 'Ошибка при очистке данных пользователя');
    }
  }
}
import 'package:clinic/core/constants/app_contants.dart';
import 'package:clinic/core/local/local_storage_service.dart';
import 'package:clinic/core/local/storage_keys.dart';
import 'package:clinic/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class TokenManager {
  // Local Storage servisi
  static final _storage = LocalStorageService();

  // Device Info olib kelish uchun
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Navigatsiya uchun global key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool _isRefreshing = false;

  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? iosInfo.name;
      }
    } catch (e) {
      log('Device ID olishda xatolik: $e');
    }

    // Unsupported platform
    throw Exception('Device ID could not be determined for this platform.');
  }

  // 401 xatolik bilan ishlash
  static Future<Response?> handle401Error(DioException error, Dio dio) async {
    // Agar token yangilash jarayonida bo'lmasak, yangilashni boshlaymiz
    if (!_isRefreshing) {
      _isRefreshing = true;

      try {
        // Refresh token olish
        final refreshToken = await _storage.getString(StorageKeys.refreshToken);

        // Refresh token mavjud bo'lsa, yangilashga harakat qilamiz
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final deviceId = await getDeviceId();

          try {
            // Refresh token so'rovini yuborish
            final refreshDio = Dio();
            final refreshResponse = await refreshDio.post(
              '${AppConstants.apiBaseUrl}refresh/',
              data: {
                'refresh_token': refreshToken,
                'device_id': deviceId,
              },
            );

            // Yangi tokenlarni tekshirish va saqlash
            if (refreshResponse.statusCode == 200 &&
                refreshResponse.data != null) {
              final accessToken = refreshResponse.data['access_token'];
              final newRefreshToken = refreshResponse.data['refresh_token'];

              if (accessToken != null && newRefreshToken != null) {
                // Yangi tokenlarni saqlash
                await _storage.setString(StorageKeys.accesToken, accessToken);
                await _storage.setString(
                    StorageKeys.refreshToken, newRefreshToken);

                // Asl so'rovni yangi token bilan qayta yuborish
                final originalRequest = error.requestOptions;
                originalRequest.headers['Authorization'] =
                    'Bearer $accessToken';

                _isRefreshing = false;

                // Dastlabki so'rovni yangi token bilan qayta yuborish
                final response = await dio.fetch(originalRequest);
                return response;
              }
            }

            // Refresh token muvaffaqiyatsiz bo'lsa, logout
            _isRefreshing = false;
            await logout();
            return null;
          } catch (refreshError) {
            // Refresh token so'rovida xatolik - logout
            log('Refresh token so\'rovida xatolik: $refreshError');
            _isRefreshing = false;
            await logout();
            return null;
          }
        } else {
          // Refresh token mavjud emas - logout
          _isRefreshing = false;
          await logout();
          return null;
        }
      } catch (e) {
        // Umumiy xatolik - logout
        log('Token yangilashda umumiy xatolik: $e');
        _isRefreshing = false;
        await logout();
        return null;
      }
    }

    // Allaqachon yangilash jarayonida bo'lsa
    return null;
  }

  // Autentifikatsiyani bekor qilish va login ekraniga yo'naltirish
  static Future<void> logout() async {
    try {
      // Local ma'lumotlarni tozalash
      await _storage.clear();
      final context = AppRouter.rootNavigatorKey.currentContext;

      if (context != null) {
        GoRouter.of(context).go('/auth');
      }
    } catch (e) {
      log('Chiqish jarayonida xatolik: $e');
    }
  }
}

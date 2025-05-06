import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class PlatformInfo {
  final Connectivity connectivity;

  PlatformInfo({required this.connectivity});

  /// Проверяет доступность сети
  Future<bool> isNetworkAvailable() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Определяет, является ли текущая платформа Android
  bool isAndroid() {
    return Platform.isAndroid;
  }

  /// Определяет, является ли текущая платформа iOS
  bool isIOS() {
    return Platform.isIOS;
  }

  /// Получает имя текущей платформы
  String getPlatformName() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isFuchsia) {
      return 'Fuchsia';
    } else {
      return 'Unknown';
    }
  }

  /// Получает версию операционной системы
  String getOSVersion() {
    return Platform.operatingSystemVersion;
  }
}
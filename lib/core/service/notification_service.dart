import 'dart:io';
import 'package:clinic/core/service/local_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    debugPrint('🔙 [Background] FCM: ${message.messageId}');
  }


static Future<void> initFCM() async {
  await _askNotificationPermission();
  await LocalNotificationService.init(); // 👉 localni boshlash

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📲 [Foreground] Xabar: ${message.messageId}');
    if (message.notification != null) {
      final title = message.notification!.title ?? 'Eslatma';
      final body = message.notification!.body ?? 'Yangi xabar keldi';
      // 🔔 Local notification
      LocalNotificationService.showNotification(title: title, body: body);
    }
  });
}


  /// Ruxsat so‘rash
  static Future<void> _askNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        debugPrint("🔔 Android notification ruxsati: $result");
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
          '🔔 iOS notification ruxsati: ${settings.authorizationStatus}');
    }
  }

  static Future<String?> getToken() async {
    return   Platform.isAndroid ? await _firebaseMessaging.getToken() : null;
  }
}

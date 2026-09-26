import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      // Android'in her cihazda bulunan standart ikonunu kullanıyoruz (Hata riskini sıfırlar)
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@android:drawable/sym_def_app_icon');

      const InitializationSettings settings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          // Bildirime tıklanınca yapılacak işlemler buraya
        },
      );
    } catch (e) {
      // Eğer burada bir hata olursa uygulama beyaz ekranda kalmasın, devam etsin.
      debugPrint("Bildirim servisi başlatılamadı: $e");
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? apartmentName,
  }) async {
    try {
      final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        summaryText: 'Yeni Gelişme',
      );

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'apartman_kanali_pro',
        'Apartman Bildirimleri VIP',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        styleInformation: bigTextStyleInformation,
        // İkon hatalarını önlemek için largeIcon'u ve özel ikonları devre dışı bıraktık
        color: const Color(0xFF2563EB),
        subText: apartmentName ?? 'Bina Yönetimi',
        category: AndroidNotificationCategory.message,
      );

      final NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
      );
    } catch (e) {
      debugPrint("Bildirim gösterilirken hata oluştu: $e");
    }
  }
}
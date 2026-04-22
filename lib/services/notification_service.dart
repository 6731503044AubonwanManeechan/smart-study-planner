import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationLevel {
  low,
  medium,
  high,
}

class NotificationService {

  /// 🔥 FCM INIT
  static Future<void> initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      showNow(
        title: message.notification?.title ?? "",
        body: message.notification?.body ?? "",
      );
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await messaging.getToken();

      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'fcmToken': token}, SetOptions(merge: true));
      }
    }
  }

  /// 🔔 schedule (แก้ fallback แล้ว)
  static Future<void> schedule({
    required String taskId,
    required DateTime deadline,
    required String title,
    required int minutesBefore,
    required bool isThai,
  }) async {

    final scheduledTime =
        deadline.subtract(Duration(minutes: minutesBefore));

    final notiTitle =
        isThai ? "งานใกล้ถึงกำหนด" : "Task Reminder";

    final notiBody = isThai
        ? "$title (อีก $minutesBefore นาที)"
        : "$title (in $minutesBefore minutes)";

    /// 🔥 FIX: ถ้าเลยเวลา → แจ้งทันที
    if (scheduledTime.isBefore(DateTime.now())) {
      showNow(
        title: notiTitle,
        body: notiBody,
      );
      return;
    }

    await notificationsPlugin.zonedSchedule(
      "$taskId-$minutesBefore".hashCode,
      notiTitle,
      notiBody,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Task Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 🔥 schedule by level
  static Future<void> scheduleByLevel({
    required String taskId,
    required DateTime deadline,
    required String title,
    required bool isThai,
    required NotificationLevel level,
  }) async {

    List<int> times = [];

    switch (level) {
      case NotificationLevel.low:
        times = [5];
        break;
      case NotificationLevel.medium:
        times = [30, 5];
        break;
      case NotificationLevel.high:
        times = [60, 30, 5];
        break;
    }

    for (var t in times) {
      await schedule(
        taskId: taskId,
        deadline: deadline,
        title: title,
        minutesBefore: t,
        isThai: isThai,
      );
    }
  }

  /// ❌ cancel
  static Future<void> cancelAll(String taskId) async {
    for (var t in [60, 30, 5]) {
      await notificationsPlugin.cancel(
        "$taskId-$t".hashCode,
      );
    }
  }

  /// 📱 show now
  static void showNow({
    required String title,
    required String body,
  }) {
    notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Task Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
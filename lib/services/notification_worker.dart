import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {

    if (task == "checkTasks") {

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return Future.value(true);

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .get();

      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['deadline'] == null) continue;
        if (data['isDone'] == true) continue;
        if (data['reminder'] != true) continue;

        final deadline =
            (data['deadline'] as Timestamp).toDate();

        final diff = deadline.difference(now);

        // 🔥 แจ้งเตือนเฉพาะช่วงใกล้ deadline
        if (diff.inMinutes <= 60 && diff.inMinutes > 0) {

          /// 🔴 กันแจ้งซ้ำ (สำคัญมาก)
          final lastNotified = data['lastNotified'];

          if (lastNotified != null) {
            final last = (lastNotified as Timestamp).toDate();

            if (DateTime.now().difference(last).inMinutes < 30) {
              continue; // ❌ ข้าม (ยังไม่ถึงเวลาแจ้งใหม่)
            }
          }

          /// 🌐 ภาษา
          final isThai = data['language'] == 'th';

          final title = isThai
              ? "งานใกล้ถึงกำหนด"
              : "Task Reminder";

          final body = data['title'] ?? "Task";

          /// 🔔 แจ้งเตือน
          NotificationService.showNow(
            title: title,
            body: body,
          );

          /// 💾 บันทึกว่าแจ้งแล้ว
          await doc.reference.update({
            'lastNotified': Timestamp.now(),
          });
        }

        /// 🔥 แจ้งเตือน "เลยกำหนด"
        if (diff.isNegative) {

          final isThai = data['language'] == 'th';

          final title = isThai
              ? "เลยกำหนดแล้ว"
              : "Task Overdue";

          final body = data['title'] ?? "Task";

          /// กัน spam overdue
          final lastNotified = data['lastNotified'];

          if (lastNotified != null) {
            final last = (lastNotified as Timestamp).toDate();

            if (DateTime.now().difference(last).inMinutes < 60) {
              continue;
            }
          }

          NotificationService.showNow(
            title: title,
            body: body,
          );

          await doc.reference.update({
            'lastNotified': Timestamp.now(),
          });
        }
      }
    }

    return Future.value(true);
  });
}
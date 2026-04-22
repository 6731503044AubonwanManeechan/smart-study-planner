import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String getRemainingText(DateTime deadline, bool isThai) {
    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (diff.isNegative) {
      return isThai ? "เลยกำหนดแล้ว" : "Overdue";
    }

    if (diff.inDays > 0) {
      return isThai ? "อีก ${diff.inDays} วัน" : "in ${diff.inDays} days";
    }

    if (diff.inHours > 0) {
      return isThai ? "อีก ${diff.inHours} ชั่วโมง" : "in ${diff.inHours} hours";
    }

    return isThai
        ? "อีก ${diff.inMinutes} นาที"
        : "in ${diff.inMinutes} minutes";
  }

  Color getLevelColor(String level) {
    switch (level) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(lang.getText("Please login", "กรุณาเข้าสู่ระบบ")),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText("Notifications", "การแจ้งเตือน")),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .orderBy('deadline')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();

          final tasks = snapshot.data!.docs;

          final upcoming = tasks.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final deadline = (data['deadline'] as Timestamp).toDate();
            return deadline.isAfter(now);
          }).toList();

          final earlier = tasks.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final deadline = (data['deadline'] as Timestamp).toDate();
            return deadline.isBefore(now);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              /// 🔔 HEADER
              Text(
                lang.getText("Notifications", "การแจ้งเตือน"),
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// 🔥 UPCOMING
              if (upcoming.isNotEmpty) ...[
                Text(
                  lang.getText("Upcoming", "กำลังจะมาถึง"),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...upcoming.map((doc) => _buildItem(doc, lang, context)),
                const SizedBox(height: 20),
              ],

              /// 🔥 EARLIER
              if (earlier.isNotEmpty) ...[
                Text(
                  lang.getText("Earlier", "ก่อนหน้านี้"),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...earlier.map((doc) => _buildItem(doc, lang, context)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(
      QueryDocumentSnapshot doc, AppLanguage lang, BuildContext context) {

    final data = doc.data() as Map<String, dynamic>;

    final title = data['title'] ?? "Task";
    final level = data['level'] ?? "medium";
    final deadline = (data['deadline'] as Timestamp).toDate();

    final isThai = lang.locale.languageCode == 'th';

    final remaining = getRemainingText(deadline, isThai);
    final color = getLevelColor(level);

    final isNew = DateTime.now().difference(deadline).inMinutes.abs() < 10;

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,

      /// 🔥 SWIPE DELETE
      onDismissed: (_) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('tasks')
            .doc(doc.id)
            .delete();
      },

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black.withOpacity(0.05),
            )
          ],
        ),

        child: Row(
          children: [

            /// 🔴 DOT LEVEL
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 12),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),

                      /// 🔥 NEW BADGE
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isThai ? "ใหม่" : "NEW",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        )
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    remaining,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            /// TIME
            Text(
              "${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
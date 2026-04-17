import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
      body: Column(
        children: [
          const SizedBox(height: 20),

          Text(
            lang.getText("Notifications", "การแจ้งเตือน"),
            style: const TextStyle(fontSize: 24),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('notifications')
                  .snapshots(), // ✅ เหลือแค่อันเดียว

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      lang.getText("No notifications", "ไม่มีการแจ้งเตือน"),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                final now = DateTime.now();

                List today = [];
                List upcoming = [];
                List earlier = [];

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  if (data['timestamp'] == null) continue;

                  final time = (data['timestamp'] as Timestamp).toDate();

                  if (time.year == now.year &&
                      time.month == now.month &&
                      time.day == now.day) {
                    today.add(doc);
                  } else if (time.isAfter(now)) {
                    upcoming.add(doc);
                  } else {
                    earlier.add(doc);
                  }
                }

                return ListView(
                  children: [
                    if (today.isNotEmpty)
                      _buildSection(
                          context,
                          lang.getText("Today", "วันนี้"),
                          today),

                    if (upcoming.isNotEmpty)
                      _buildSection(
                          context,
                          lang.getText("Upcoming", "กำลังจะมา"),
                          upcoming),

                    if (earlier.isNotEmpty)
                      _buildSection(
                          context,
                          lang.getText("Earlier", "ก่อนหน้านี้"),
                          earlier),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List docs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        ...docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return ListTile(
            title: Text(data['title'] ?? ""),
            subtitle: Text(data['message'] ?? ""),
          );
        }).toList(),
      ],
    );
  }
}
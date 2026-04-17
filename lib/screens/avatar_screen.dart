import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class AvatarScreen extends StatelessWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final avatars = List.generate(
        35, (i) => "assets/images/Avt${i + 1}.png");

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: avatars.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final path = avatars[index];

            return GestureDetector(
              onTap: () {
                /// 🔥 ส่งค่ากลับ (ไม่ save)
                Navigator.pop(context, path);
              },
              child: CircleAvatar(
                backgroundImage: AssetImage(path),
              ),
            );
          },
        ),
      ),
    );
  }
}
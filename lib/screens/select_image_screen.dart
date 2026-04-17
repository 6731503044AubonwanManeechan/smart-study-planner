import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class SelectImageScreen extends StatelessWidget {
  const SelectImageScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final images = List.generate(
      34,
      (index) => "assets/images/add${index + 1}.png",
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE9E6ED),
      appBar: AppBar(
        title: const Text("Select Subject Icon"),
        backgroundColor: const Color(0xFF5FAAE3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, images[index]); // 🔥 ส่งค่ากลับ
              },
              child: CircleAvatar(
                backgroundImage: AssetImage(images[index]),
                radius: 30,
              ),
            );
          },
        ),
      ),
    );
  }
}
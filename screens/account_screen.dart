import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';
import 'avatar_screen.dart';
import '../providers/theme_provider.dart';
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  User? get user => FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  String? selectedAvatar;

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? "";
  }

  Future<void> save() async {
    final user = FirebaseAuth.instance.currentUser;

    await user?.updateDisplayName(nameController.text.trim());

    if (selectedAvatar != null) {
      await user?.updatePhotoURL(selectedAvatar);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .set({"avatar": selectedAvatar}, SetOptions(merge: true));
    }

    await user?.reload();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// 🔥 rowText รองรับ 2 ภาษา
  Widget rowText(String en, String th, String value, AppLanguage lang, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
            fontSize: 15,
            height: 1.25,
          ),
          children: [
            TextSpan(
              text: "${lang.getText(en, th)} : ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  final lang = Provider.of<AppLanguage>(context);

  /// 🔥 ใส่ตรงนี้เลย
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFEDE7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              /// 🔙 Back
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.brown),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// 🔥 Title
              Text(
                lang.getText("Account", "บัญชี"),
                style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              ),

              const SizedBox(height: 20),

              /// Avatar
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AvatarScreen(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      selectedAvatar = result;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: Image.asset(
                      selectedAvatar ??
                          (user?.photoURL != null &&
                                  user!.photoURL!.startsWith("assets/")
                              ? user!.photoURL!
                              : "assets/images/account.png"),
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// 🔥 INFO CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black12,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(user!.uid)
                      .collection("tasks")
                      .snapshots(),
                  builder: (context, snapshot) {

                    int doneCount = 0;
                    int days = 0;

                    if (snapshot.hasData) {
                      final docs = snapshot.data!.docs;

                      doneCount = docs
                          .where((d) => d['isDone'] == true)
                          .length;

                      days = docs
                          .where((doc) =>
                              doc.data().toString().contains("createdAt"))
                          .map((e) =>
                              (e['createdAt'] as Timestamp).toDate())
                          .map((date) =>
                              DateTime(date.year, date.month, date.day))
                          .toSet()
                          .length;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// Name
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                "${lang.getText("Name", "ชื่อ")} : ",
                                style:TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style:  TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 4),

                        rowText("Email", "อีเมล", user?.email ?? "", lang, isDark),
                        rowText("Task Done", "งานที่เสร็จ", "$doneCount", lang, isDark),
                        rowText("Streak", "สถิติ", "$days ${lang.getText("day", "วัน")}", lang, isDark),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 APP INFO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black12,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${lang.getText("App Version", "เวอร์ชัน")} : 1.0.0"),
                    const SizedBox(height: 5),
                    Text(
                      lang.getText(
                        "User Guide : Detailed instructions on how to use all features.",
                        "คู่มือผู้ใช้ : วิธีใช้งานแอปทั้งหมด",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// 🔥 BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(lang.getText("Cancel", "ยกเลิก")),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5FAAE3),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(130, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        lang.getText("Save", "บันทึก"),
                        style:  TextStyle(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';
import '../providers/theme_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/help_support_screen.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  bool isCalendarChecked = true;
  bool isWorkChecked = true;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);

    /// 🔥 เพิ่มตรงนี้ (สำคัญมาก)
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Drawer(
      child: SafeArea(
        child: Container(
          color: isDark ? Colors.black : Colors.white, /// 🔥 เปลี่ยนพื้นหลัง
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              /// ===== TITLE =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Smart Study Planner",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF4A86C5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ===== PROFILE =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : const AssetImage("assets/images/account.png")
                              as ImageProvider,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        user?.email ?? "",
                        style: TextStyle(
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              const Divider(),

              /// ===== MY CALENDAR =====
              CheckboxListTile(
                activeColor: const Color(0xFF6C4AB6),
                value: isCalendarChecked,
                onChanged: (value) {
                  setState(() {
                    isCalendarChecked = value!;
                  });
                },
                title: Text(
                  lang.getText("My calendar", "ปฏิทินของฉัน"),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              /// ===== WORK =====
              CheckboxListTile(
                activeColor: const Color(0xFF6C4AB6),
                value: isWorkChecked,
                onChanged: (value) {
                  setState(() {
                    isWorkChecked = value!;
                  });
                },
                title: Text(
                  lang.getText("Work", "งาน"),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const Divider(),

              /// ===== SETTINGS ===== 🔥 แก้ตรงนี้แล้ว
              ListTile(
                leading: Image.asset(
                  isDark
                      ? "assets/images/setting2.png"
                      : "assets/images/Setting.png",
                  width: 22,
                ),
                title: Text(
                  lang.getText("Setting", "ตั้งค่า"),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),

              /// ===== SEND FEEDBACK ===== 🔥 แก้แล้ว
              ListTile(
                leading: Image.asset(
                  isDark
                      ? "assets/images/Send3.png"
                      : "assets/images/Send.png",
                  width: 22,
                ),
                title: Text(
                  lang.getText("Send feedback", "ส่งความคิดเห็น"),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        lang.getText("Feedback clicked", "ส่งความคิดเห็นแล้ว"),
                      ),
                    ),
                  );
                },
              ),

              /// ===== HELP =====
              ListTile(
                title: Text(
                  lang.getText("Help & Support", "ช่วยเหลือและสนับสนุน"),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Image.asset(
                  "assets/images/next.png",
                  width: 18,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
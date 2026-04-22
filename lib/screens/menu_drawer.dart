import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';
import '../providers/theme_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/help_support_screen.dart';
import '../screens/send_feedback_screen.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Drawer(
      child: SafeArea(
        child: Container(
          color: isDark ? Colors.black : Colors.white,
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

              const SizedBox(height: 25),
              const Divider(),

              /// ===== SETTING =====
              ListTile(
                leading: Image.asset(
                  isDark
                      ? "assets/images/setting2.png"
                      : "assets/images/setting.png",
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

              /// ===== SEND FEEDBACK =====
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SendFeedbackScreen(),
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
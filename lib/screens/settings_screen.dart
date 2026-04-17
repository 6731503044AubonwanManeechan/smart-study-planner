import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool restMode = false;

  /// 🔘 Language button
  Widget buildOptionButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B0000) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 🌗 Theme button
  Widget buildThemeButton({
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[300] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Image.asset(
          imagePath,
          width: 28,
          height: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    /// 🔥 ตัวสำคัญ
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFECECEC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [

              /// 🔙 Back
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : const Color(0xFF8B0000),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 5),

              /// 🔥 Title
              Text(
                lang.getText("Settings", "ตั้งค่า"),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              /// 🔥 Card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFB22222),
                  ),
                ),
                child: Column(
                  children: [

                    /// 🔔 Notifications
                    ListTile(
                      title: Text(
                        lang.getText("Notifications", "การแจ้งเตือน"),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Switch(
                        value: notifications,
                        onChanged: (val) {
                                  setState(() {
                                    restMode = val;
                                  });

                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user == null) return;

                                  if (val) {
                                    startEyeRestTimer(user); // ✅ เริ่มส่ง email
                                  } else {
                                    stopEyeRestTimer(); // ❌ หยุด
                                  }
                                },
                        activeColor: Colors.green,
                      ),
                    ),

                    /// 😴 Rest Mode
                    ListTile(
                      title: Text(
                        lang.getText("Rest Mode Reminder", "แจ้งเตือนพักสายตา"),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Switch(
                        value: restMode,
                        onChanged: (val) {
                          setState(() {
                            restMode = val;
                          });
                        },
                      ),
                    ),

                    /// 🌐 Language
                    ListTile(
                      title: Text(
                        lang.getText("Language", "ภาษา"),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildOptionButton(
                            text: "EN",
                            isSelected: lang.language == "en",
                            onTap: () {
                              lang.changeLanguage("en");
                            },
                          ),
                          const SizedBox(width: 8),
                          buildOptionButton(
                            text: "TH",
                            isSelected: lang.language == "th",
                            onTap: () {
                              lang.changeLanguage("th");
                            },
                          ),
                        ],
                      ),
                    ),

                    /// 🎨 Theme
                    ListTile(
                      title: Text(
                        lang.getText("Theme", "ธีม"),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildThemeButton(
                            imagePath: "assets/images/light.png",
                            isSelected: !isDark,
                            onTap: () {
                              themeProvider.setLightMode();
                            },
                          ),
                          const SizedBox(width: 10),
                          buildThemeButton(
                            imagePath: "assets/images/Dark.png",
                            isSelected: isDark,
                            onTap: () {
                              themeProvider.setDarkMode();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// 🚪 Log Out
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      lang.getText("Log Out", "ออกจากระบบ"),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
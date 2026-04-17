import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import 'calendar_screen.dart';
import 'notifications_screen.dart';
import 'menu_drawer.dart';
import 'account_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String? _userPhotoFromFirestore;

  User? get user => FirebaseAuth.instance.currentUser;
  String get userId => user!.uid;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.userChanges().listen((event) {
      setState(() {});
    });
  }

ImageProvider? _getProfileImage() {

  /// 🔥 ถ้าเป็น asset (สำคัญ)
  if (user?.photoURL != null &&
      user!.photoURL!.startsWith("assets/")) {
    return AssetImage(user!.photoURL!);
  }

  /// 🔥 ถ้าเป็น network
  if (user?.photoURL != null &&
      user!.photoURL!.isNotEmpty) {
    return NetworkImage(user!.photoURL!);
  }

  return null;
}

  /// ✅ Toggle task (แก้แล้ว)
  void toggleTask(TaskModel task) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .update({
      "isDone": !task.isDone,
    });
  }

  /// ✅ ลบ task
  Future<void> deleteTask(String taskId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  /// ✅ popup confirm
void confirmDelete(String taskId) {
  final lang = Provider.of<AppLanguage>(context, listen: false);

  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.themeMode == ThemeMode.dark;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                lang.getText(
                  "Are you sure you want to delete this subject?",
                  "คุณแน่ใจหรือไม่ที่จะลบวิชานี้",
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(lang.getText("Cancel", "ยกเลิก")),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      await deleteTask(taskId);
                      Navigator.pop(context);
                    },
                    child: Text(lang.getText("Confirm", "ยืนยัน")),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  /// คำนวณ progress
  double calculateProgress(List<TaskModel> tasks) {
    if (tasks.isEmpty) return 0;

    int totalMinutes =
        tasks.fold(0, (sum, task) => sum + task.duration);

    int doneMinutes = tasks
        .where((t) => t.isDone)
        .fold(0, (sum, task) => sum + task.duration);

    if (totalMinutes == 0) return 0;

    return doneMinutes / totalMinutes;
  }

String getTodaySubject(List<TaskModel> tasks) {
  if (tasks.isEmpty) {
    return "No tasks yet";
  }

  try {
    final nextTask =
        tasks.firstWhere((task) => !task.isDone);
    return nextTask.title.split("-").first.trim();
  } catch (e) {
    return "All Done for Today! 🎉";
  }
}

String getAchievementIcon(double progress) {
  int percent = (progress * 100).toInt();

  if (percent >= 100) return "assets/images/IC10.png";
  if (percent >= 90) return "assets/images/IC9.png";
  if (percent >= 80) return "assets/images/IC8.png";
  if (percent >= 70) return "assets/images/IC7.png";
  if (percent >= 60) return "assets/images/IC6.png";
  if (percent >= 50) return "assets/images/IC5.png";
  if (percent >= 40) return "assets/images/IC4.png";
  if (percent >= 30) return "assets/images/IC3.png";
  if (percent >= 20) return "assets/images/IC2.png";
  return "assets/images/IC1.png";
}

@override
Widget build(BuildContext context) {

  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
    backgroundColor: isDark ? Colors.black : const Color(0xFFECEAF1),
      drawer: const MenuDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          const CalendarScreen(),
          const NotificationsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B1E1E),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/home.png')),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/calendar.png')),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/notifications.png')),
            label: '',
          ),
        ],
      ),
    );
  }

Widget _buildHomeTab() {
  final lang = Provider.of<AppLanguage>(context);

  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDark = themeProvider.themeMode == ThemeMode.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .snapshots(),
      builder: (context, snapshot) {

  if (snapshot.hasError) {
    return Center(child: Text("Error: ${snapshot.error}"));
  }

  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  }

  if (!snapshot.hasData) {
  return const Center(child: CircularProgressIndicator());
}

final docs = snapshot.data!.docs;

/// 🔥 แปลงเป็น TaskModel (สำคัญ)
final allTasks = docs
    .map((doc) => TaskModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        ))
    .toList();

/// 🔥 days (Realtime)
final days = docs.isEmpty
    ? 0
    : docs
        .where((doc) =>
            doc.data().toString().contains("createdAt"))
        .map((e) =>
            (e['createdAt'] as Timestamp?)?.toDate())
        .where((date) => date != null)
        .map((date) =>
            DateTime(date!.year, date.month, date.day))
        .toSet()
        .length;

/// 🔥 ใช้คำนวณ (ต้องเอาทั้งหมด)
double progress =
    allTasks.isEmpty ? 0 : calculateProgress(allTasks);

/// 🔥 ใช้แสดง (เอาเฉพาะยังไม่เสร็จ)
final tasks = allTasks.where((task) => !task.isDone).toList();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Smart Study Planner",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Color(0xFF3A78B5),
                      ),
                    ),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu,
                            color: Color(0xFF8B1E1E)),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                /// Hello
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccountScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _getProfileImage(),
                          child: _getProfileImage() == null
                              ? const Icon(Icons.person, size: 22)
                              : null,
                    ),
                      ), // ✅ ต้องมีตัวนี้

                      const SizedBox(width: 10),

                      Text(
                        "${lang.getText("Hello", "สวัสดี")}, ${user?.displayName ?? ""}",
                        style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),

                /// Progress Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F1E8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF8B1E1E),
                        width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              color:
                                  const Color(0xFF8B1E1E),
                              backgroundColor:
                                  Colors.grey.shade300,
                            ),
                          ),
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ??
                                  "No Name",
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold),
                            ),
                            Text(user?.email ?? ""),
                            const SizedBox(height: 5),
                            Text(lang.getText("Daily Progress", "ความคืบหน้า")),
                            Text(
                                "${lang.getText("Today", "วันนี้")} : ${getTodaySubject(tasks)}",
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black12,
              )
            ],
          ),
          child: Row(
            children: [

      /// 🔥 ICON เปลี่ยนตาม %
      Image.asset(
        getAchievementIcon(progress),
        width: 55,
      ),

      const SizedBox(width: 15),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 DAYS
            Text(
                "${lang.getText("Streak", "สถิติ")} : $days ${lang.getText("days", "วัน")}",
                style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            /// 🔥 PROGRESS
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            )
          ],
        ),
      )
    ],
  ),
),

                /// Tasks
                /// Tasks
            if (tasks.isEmpty)
              Center(child: Text(lang.getText("No tasks yet", "ยังไม่มีงาน")))
            else
              Column(
                children: tasks.map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _taskItem(task),
                  );
                }).toList(),
              ),
              ],
            ),
          ),
        );
      },
    );
  }

Widget _taskItem(TaskModel task) {

  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDark = themeProvider.themeMode == ThemeMode.dark;

  return GestureDetector(
    onTap: () => toggleTask(task),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: isDark
          ? const Color(0xFF2A2A2A)
          : (task.isDone
              ? const Color(0xFFD8C5E6)
              : const Color(0xFFF4E6C8)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(
            task.isDone
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: task.isDone ? Colors.green : Colors.grey,
          ),

          const SizedBox(width: 14),

          /// 🔥 แก้ตรงนี้
          Image.asset(
            task.image,
            width: 45,
            height: 45,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text("${task.duration} min"),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => confirmDelete(task.id),
          ),
        ],
      ),
    ),
  );
}
}
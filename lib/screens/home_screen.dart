import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'settings_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<TaskModel> _tasks = [
    TaskModel(id: "1", title: "Mathe - Ch 3", duration: 45, isDone: false),
    TaskModel(id: "2", title: "Probability - Ch 5-6", duration: 50, isDone: true),
    TaskModel(id: "3", title: "English - Conjunctions", duration: 45, isDone: false),
    TaskModel(id: "4", title: "Chemistry - Chemical bonds", duration: 45, isDone: false),
  ];

  double calculateProgress() {
    if (_tasks.isEmpty) return 0;
    final done = _tasks.where((t) => t.isDone).length;
    return done / _tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAF1),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          const CalendarScreen(),
          const SettingsScreen(),
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
            icon: ImageIcon(AssetImage('assets/images/home.png'), size: 24),
            activeIcon:
                ImageIcon(AssetImage('assets/images/home.png'), size: 28),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/calendar.png'), size: 24),
            activeIcon:
                ImageIcon(AssetImage('assets/images/calendar.png'), size: 28),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/notifications.png'), size: 24),
            activeIcon:
                ImageIcon(AssetImage('assets/images/notifications.png'), size: 28),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    int doneCount = _tasks.where((t) => t.isDone).length;
    int percent = (calculateProgress() * 100).toInt();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Smart Study Planner",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A78B5),
                  ),
                ),
                Image.asset(
                  "assets/images/menu.png",
                  width: 26,
                  color: const Color(0xFF8B1E1E),
                )
              ],
            ),
            const SizedBox(height: 20),

            /// 🔹 Hello Row
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      AssetImage("assets/images/account.png"),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Hello , Aubolwan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 Progress Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F1E8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF8B1E1E), width: 1.5),
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
                          value: calculateProgress(),
                          strokeWidth: 8,
                          color: const Color(0xFF8B1E1E),
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      Text(
                        "$percent%",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Aubolwan Maneechan",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text("aubolwan@gmail.com"),
                        const SizedBox(height: 4),
                        Text("Daily Progress"),
                        Text("Today : Math"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🔹 Task List
            Column(
              children: _tasks.map((task) {
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
  }

  Widget _taskItem(TaskModel task) {
    String imagePath = "assets/images/book.png";

  if (task.title.contains("Mathe")) {
    imagePath = "assets/images/mathe.png";
  } else if (task.title.contains("Probability")) {
    imagePath = "assets/images/probability.png";
  } else if (task.title.contains("English")) {
    imagePath = "assets/images/english.png";
  } else if (task.title.contains("Chemistry")) {
    imagePath = "assets/images/chemistry.png";
  }
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: task.isDone
            ? const Color(0xFFD8C5E6) // purple
            : const Color(0xFFF4E6C8), // beige
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
            task.isDone ? Icons.check_circle : Icons.circle_outlined,
            color: task.isDone ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "(${task.duration} minute)",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
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
      backgroundColor: const Color(0xFFE9E6ED),
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/home.png'),
              size: 24,
            ),
            activeIcon: ImageIcon(
              AssetImage('assets/images/home.png'),
              size: 26,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/calendar.png'),
              size: 24,
            ),
            activeIcon: ImageIcon(
              AssetImage('assets/images/calendar.png'),
              size: 26,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/manage.png'),
              size: 24,
            ),
            activeIcon: ImageIcon(
              AssetImage('assets/images/manage.png'),
              size: 26,
            ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Smart Study Planner",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A78B5),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
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
                        ),
                      ),
                      Text(
                        "$percent%",
                        style: const TextStyle(
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
                        const SizedBox(height: 6),
                        const Text("aubolwan@gmail.com"),
                        const SizedBox(height: 6),
                        Text("Task Done : $doneCount"),
                        const Text("Streak : 6 day"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: task.isDone ? Colors.green[100] : Colors.orange[100],
      ),
      child: Row(
        children: [
          Icon(
            task.isDone ? Icons.check_circle : Icons.circle_outlined,
            color: task.isDone ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("(${task.duration} min)"),
            ],
          ),
        ],
      ),
    );
  }
}

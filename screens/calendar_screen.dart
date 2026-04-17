import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';
import '../models/task_model.dart';
import 'add_study_task_screen.dart';
import '../providers/theme_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  User? get user => FirebaseAuth.instance.currentUser;
  String get userId => user?.uid ?? "";

  Map<DateTime, List<TaskModel>> _events = {};

  List<TaskModel> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _loadTasks(List<TaskModel> tasks) {
    final Map<DateTime, List<TaskModel>> data = {};

    for (var task in tasks) {
      final date = DateTime(
        task.dateTime.year,
        task.dateTime.month,
        task.dateTime.day,
      );

      data.putIfAbsent(date, () => []);
      data[date]!.add(task);
    }

    _events = data;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);

    final themeProvider = Provider.of<ThemeProvider>(context);
final isDark = themeProvider.themeMode == ThemeMode.dark;

    /// ❗ login check
    if (user == null || userId.isEmpty) {
      return Center(
        child: Text(
          lang.getText("Please login", "กรุณาเข้าสู่ระบบ"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFE9E6ED),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD8BFE8),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddStudyTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!.docs.map((doc) {
            return TaskModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();

          _loadTasks(tasks);

          final selectedTasks =
              _getEventsForDay(_selectedDay ?? _focusedDay);

          return SafeArea(
            child: Column(
              children: [

                const SizedBox(height: 20),

                /// 🔥 Title
                Text(
                  lang.getText("Calendar", "ปฏิทิน"),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// 📅 Calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: _onDaySelected,
                      eventLoader: _getEventsForDay,
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 📋 Task list
                Expanded(
                  child: selectedTasks.isEmpty
                      ? Center(
                          child: Text(
                            lang.getText(
                              "No tasks for this day",
                              "ไม่มีงานในวันนี้",
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: selectedTasks.length,
                          itemBuilder: (context, index) {
                            final task = selectedTasks[index];

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                ? const Color(0xFF2A2A2A)
                                : (task.isDone ? Colors.grey[300] : Colors.white),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: task.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  Text("${task.duration} min"),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime(2026, 2);
  DateTime? _selectedDay = DateTime(2026, 2, 5);
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E6ED),
      body: SafeArea(
        child: Stack(
          children: [

            /// ================= MAIN CONTENT =================
            SingleChildScrollView(
              child: Column(
                children: [

                  const SizedBox(height: 70),

                  /// ===== TITLE =====
                  const Text(
                    "Calendar",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ===== CALENDAR CARD =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          )
                        ],
                      ),
                      child: TableCalendar(
                        firstDay: DateTime(2000),
                        lastDay: DateTime(2100),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          leftChevronIcon: Icon(Icons.chevron_left),
                          rightChevronIcon: Icon(Icons.chevron_right),
                        ),
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// ===== UPCOMING SECTION =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9CFB8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Upcoming",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 25),

                        _upcomingCard(
                          "February 15th: Read math textbook + English summary.",
                        ),

                        const SizedBox(height: 25),

                        _upcomingCard(
                          "February 19th: Read chemistry book + summary of statistics and probability.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ================= TOP LEFT =================
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      "assets/images/back.png",
                      width: 26,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/menu.png",
                    width: 26,
                  ),
                ],
              ),
            ),

            /// ================= TOP RIGHT =================
            Positioned(
              top: 20,
              right: 20,
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/calendar2.png",
                    width: 26,
                  ),
                  const SizedBox(width: 20),
                  Image.asset(
                    "assets/images/setting2.png",
                    width: 26,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _upcomingCard(String text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}

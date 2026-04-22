import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';


class AddStudyTaskScreen extends StatefulWidget {
  const AddStudyTaskScreen({super.key});

  @override
  State<AddStudyTaskScreen> createState() => _AddStudyTaskScreenState();
}

class _AddStudyTaskScreenState extends State<AddStudyTaskScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay _deadlineTime = TimeOfDay.now();

  String _priority = "Medium";
  bool _reminder = false;

  String _selectedImage = "assets/images/add1.png";

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  /// ✅ เลือกรูป
  void _selectImage() async {
    final images = List.generate(
      34,
      (index) => "assets/images/add${index + 1}.png",
    );

    final result = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(15),
            height: 350,
            child: GridView.builder(
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final isSelected = _selectedImage == images[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, images[index]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage: AssetImage(images[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedImage = result;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    DateTime endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _deadlineTime.hour,
      _deadlineTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    final duration = endDateTime.difference(startDateTime).inMinutes;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add({
      "title": _subjectController.text,
      "deadline": Timestamp.fromDate(startDateTime),
      "duration": duration,
      "priority": _priority,
      "reminder": _reminder,
      "isDone": false,
      "createdAt": Timestamp.now(),
      "image": _selectedImage,
    });

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    bool enabled = userDoc.data()?['notificationsEnabled'] ?? true;

    if (_reminder && enabled) {
      final lang = Provider.of<AppLanguage>(context, listen: false);

      NotificationLevel level =
          _priority == "Low"
              ? NotificationLevel.low
              : _priority == "High"
                  ? NotificationLevel.high
                  : NotificationLevel.medium;

      await NotificationService.scheduleByLevel(
        taskId: doc.id,
        deadline: startDateTime,
        title: _subjectController.text,
        isThai: lang.locale.languageCode == 'th',
        level: level,
      );
    }

    Navigator.pop(context);
  }

  Widget _inputBox({required Widget child}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {

    final lang = Provider.of<AppLanguage>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFE9E6ED),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.black54, width: 1.2),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Center(
                      child: Text(
                        lang.getText("Add Study Task", "เพิ่มแผนการเรียน"),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5FAAE3),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔥 รูป + ดินสอ
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: AssetImage(_selectedImage),
                          ),
                          GestureDetector(
                            onTap: _selectImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Icon(Icons.edit, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(lang.getText("Subject", "วิชา")),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// START DATE + TIME
                    Column(
                      children: [

                        Row(
                          children: [
                            Expanded(child: Text("Start Date")),
                            const SizedBox(width: 10),
                            Expanded(child: Text("Start Time")),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) setState(() => _selectedDate = picked);
                                },
                                child: _inputBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                                      const Icon(Icons.calendar_today, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedTime,
                                  );
                                  if (picked != null) setState(() => _selectedTime = picked);
                                },
                                child: _inputBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_selectedTime.format(context)),
                                      const Icon(Icons.access_time, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// END DATE + TIME
                    Column(
                    children: [

                      Row(
                        children: [
                          Expanded(child: Text("End Date")),
                          const SizedBox(width: 10),
                          Expanded(child: Text("End Time")),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) setState(() => _endDate = picked);
                              },
                              child: _inputBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${_endDate.day}/${_endDate.month}/${_endDate.year}"),
                                    const Icon(Icons.calendar_today, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: _deadlineTime,
                                );
                                if (picked != null) setState(() => _deadlineTime = picked);
                              },
                              child: _inputBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_deadlineTime.format(context)),
                                    const Icon(Icons.access_time, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                    const SizedBox(height: 20),

                    /// 🔥 PRIORITY
                  Text(lang.getText("Priority", "ลำดับความสำคัญ")),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Low", child: Text("Low")),
                      DropdownMenuItem(value: "Medium", child: Text("Medium")),
                      DropdownMenuItem(value: "High", child: Text("High")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                  ),

                    CheckboxListTile(
                      value: _reminder,
                      title: Text(lang.getText("Reminder", "แจ้งเตือน")),
                      onChanged: (value) {
                        setState(() => _reminder = value!);
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          /// ❌ Cancel
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : Colors.black, // 🔥 ปรับตามโหมด
                              side: BorderSide(
                                color: isDark ? Colors.white38 : Colors.black38, // 🔥 เส้นนุ่มขึ้น
                              ),
                              minimumSize: const Size(130, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(lang.getText("Cancel", "ยกเลิก")),
                          ),

                          /// ✅ Save
                          ElevatedButton(
                            onPressed: _saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5FAAE3),
                              foregroundColor: Colors.white,
                              elevation: 2, // 🔥 เพิ่มเงาให้ดูดีขึ้น
                              minimumSize: const Size(130, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(lang.getText("Save", "บันทึก")),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
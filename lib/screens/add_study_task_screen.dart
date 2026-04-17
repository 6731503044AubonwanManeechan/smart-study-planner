import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';
import '../providers/theme_provider.dart';

class AddStudyTaskScreen extends StatefulWidget {
  const AddStudyTaskScreen({super.key});

  @override
  State<AddStudyTaskScreen> createState() => _AddStudyTaskScreenState();
}

class _AddStudyTaskScreenState extends State<AddStudyTaskScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  int _duration = 30;
  String _priority = "Medium";
  bool _reminder = false;

  String _selectedImage = "assets/images/add1.png";

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add({
      "title": _subjectController.text,
      "dateTime": Timestamp.fromDate(dateTime),
      "duration": _duration,
      "priority": _priority,
      "reminder": _reminder,
      "isDone": false,
      "createdAt": Timestamp.now(),
      "image": _selectedImage,
    });

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
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 400,
            child: GridView.builder(
              itemCount: images.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, images[index]);
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage(images[index]),
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

                    /// 🔥 Header
                    Center(
                      child: Column(
                        children: [
                          Text(
                            lang.getText("Add Study Task", "เพิ่มแผนการเรียน"),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5FAAE3),
                            ),
                          ),

                          const SizedBox(height: 15),

                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(_selectedImage),
                              ),
                              GestureDetector(
                                onTap: _selectImage,
                                child: const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey,
                                  child: Icon(Icons.edit,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Subject
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
                      validator: (value) =>
                          value!.isEmpty
                              ? lang.getText("Enter subject", "กรอกชื่อวิชา")
                              : null,
                    ),

                    const SizedBox(height: 20),

                    /// Date
                    Text(lang.getText("Date", "วันที่")),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: _inputBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [

                        /// Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang.getText("Time", "เวลา")),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedTime,
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedTime = picked;
                                    });
                                  }
                                },
                                child: _inputBox(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_selectedTime.format(context)),
                                      const Icon(Icons.access_time),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 15),

                        /// Duration
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang.getText("Duration", "ระยะเวลา")),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: _duration,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(15),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 30, child: Text("30 minutes")),
                                  DropdownMenuItem(value: 60, child: Text("1 hour")),
                                  DropdownMenuItem(value: 120, child: Text("2 hours")),
                                  DropdownMenuItem(value: 180, child: Text("3 hours")),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _duration = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Priority
                    Text(lang.getText("Priority", "ความสำคัญ")),
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

                    const SizedBox(height: 20),

                    /// Reminder
                    CheckboxListTile(
                      value: _reminder,
                      title: Text(lang.getText("Reminder", "แจ้งเตือน")),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          _reminder = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [

                        /// Cancel
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(lang.getText("Cancel", "ยกเลิก")),
                          ),
                        ),

                        const SizedBox(width: 20),

                        /// Save
                        Expanded(
                        child: ElevatedButton(
                          onPressed: _saveTask,
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
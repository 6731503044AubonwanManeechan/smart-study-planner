import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final int duration;
  final bool isDone;
  final DateTime dateTime;
  final String image;
  final DateTime? createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.isDone,
    required this.dateTime,
    required this.image,
    this.createdAt,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    int? duration,
    bool? isDone,
    DateTime? dateTime,
    String? image,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      isDone: isDone ?? this.isDone,
      dateTime: dateTime ?? this.dateTime,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'duration': duration,
      'isDone': isDone,

      // 🔥 เปลี่ยนเป็น deadline
      'deadline': Timestamp.fromDate(dateTime),

      'createdAt': Timestamp.now(),
      'image': image,
    };
  }

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {

    // 🔥 รองรับทั้ง deadline + dateTime (สำคัญมาก)
    final rawTime = map['deadline'] ?? map['dateTime'];

    DateTime parsedDate;

    if (rawTime != null && rawTime is Timestamp) {
      parsedDate = rawTime.toDate();
    } else {
      parsedDate = DateTime.now(); // กันพัง
    }

    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      duration: map['duration'] ?? 0,
      isDone: map['isDone'] ?? false,
      dateTime: parsedDate,
      image: map['image'] ?? 'assets/images/add1.png',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
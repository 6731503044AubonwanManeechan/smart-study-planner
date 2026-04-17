import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final int duration;
  final bool isDone;
  final DateTime dateTime;
  final String image;

  TaskModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.isDone,
    required this.dateTime,
    required this.image,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    int? duration,
    bool? isDone,
    DateTime? dateTime,
    String? image, // ✅ เพิ่ม
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      isDone: isDone ?? this.isDone,
      dateTime: dateTime ?? this.dateTime,
      image: image ?? this.image, // ✅ เพิ่ม
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'duration': duration,
      'isDone': isDone,
      'dateTime': Timestamp.fromDate(dateTime),
      'image': image, // ✅ เพิ่ม
    };
  }

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      duration: map['duration'] ?? 0,
      isDone: map['isDone'] ?? false,
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      image: map['image'] ?? 'assets/images/add1.png',
    );
  }
}
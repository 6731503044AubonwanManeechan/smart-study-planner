class TaskModel {
  final String id;
  final String title;
  final int duration;
  final bool isDone;

  TaskModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.isDone,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'duration': duration,
      'isDone': isDone,
    };
  }

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      title: map['title'],
      duration: map['duration'],
      isDone: map['isDone'],
    );
  }
}

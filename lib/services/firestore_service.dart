import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  CollectionReference get _taskRef => _db
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('tasks');

  Future<void> addTask(TaskModel task) async {
    await _taskRef.add(task.toMap());
  }

  Stream<List<TaskModel>> getTasks() {
    return _taskRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) {
          return TaskModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>);
        }).toList());
  }

  Future<void> toggleTask(TaskModel task) async {
    await _taskRef.doc(task.id).update({
      'isDone': !task.isDone,
    });
  }
}

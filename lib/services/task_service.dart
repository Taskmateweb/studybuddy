import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Get all tasks for current user
  Stream<List<Task>> getUserTasks() {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        return Task.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Sort by createdAt on client side to avoid index requirement
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Descending order
      
      return tasks;
    });
  }

  // Get today's tasks
  Stream<List<Task>> getTodaysTasks() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      // Filter today's tasks on client side to avoid index requirement
      final allTasks = snapshot.docs.map((doc) {
        return Task.fromMap(doc.data(), doc.id);
      }).toList();

      // Filter tasks for today
      final todaysTasks = allTasks.where((task) {
        if (task.dueDate == null) return false;
        final taskDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        return taskDate == startOfDay;
      }).toList();

      // Sort by due date
      todaysTasks.sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

      return todaysTasks;
    });
  }

  // Add a new task
  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? category,
    int priority = 2,
  }) async {
    if (_userId.isEmpty) throw Exception('User not logged in');

    final task = Task(
      id: '', // Will be set by Firestore
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: false,
      userId: _userId,
      createdAt: DateTime.now(),
      category: category,
      priority: priority,
    );

    await _firestore.collection('tasks').add(task.toMap());
  }

  // Update task
  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': !isCompleted,
      'completedAt': !isCompleted ? DateTime.now().toIso8601String() : null,
    });
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  // Get task count
  Future<int> getTaskCount({bool? isCompleted}) async {
    Query query = _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _userId);

    if (isCompleted != null) {
      query = query.where('isCompleted', isEqualTo: isCompleted);
    }

    final snapshot = await query.get();
    return snapshot.docs.length;
  }

  // Get completed tasks today
  Future<int> getCompletedTasksToday() async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .where('isCompleted', isEqualTo: true)
        .get();

    return snapshot.docs.length;
  }

  // Stream of completed tasks count (real-time updates)
  Stream<int> getCompletedTasksTodayStream() {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .where('isCompleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import 'task_notification_service.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TaskNotificationService _notificationService = TaskNotificationService();

  String get _userId => _auth.currentUser?.uid ?? '';

  // Get all tasks for current user
  Stream<List<Task>> getUserTasks() {
    print('🔷 TaskService - Getting tasks for userId: $_userId');
    
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      print('🔷 TaskService - Received ${snapshot.docs.length} documents');
      
      final tasks = snapshot.docs.map((doc) {
        try {
          final task = Task.fromMap(doc.data(), doc.id);
          print('🔷 TaskService - Parsed task: ${task.title}');
          return task;
        } catch (e) {
          print('🔷 TaskService - Error parsing task ${doc.id}: $e');
          rethrow;
        }
      }).toList();
      
      // Sort by createdAt on client side to avoid index requirement
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Descending order
      
      print('🔷 TaskService - Returning ${tasks.length} tasks');
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
        // Prefer startAt date if present, else dueDate
        DateTime? dateRef = task.startAt ?? task.dueDate;
        if (dateRef == null) return false;
        final taskDate = DateTime(dateRef.year, dateRef.month, dateRef.day);
        return taskDate == startOfDay;
      }).toList();

      // Sort by due date
      todaysTasks.sort((a, b) {
        // Sort by startAt if available, else dueDate
        final aRef = a.startAt ?? a.dueDate;
        final bRef = b.startAt ?? b.dueDate;
        if (aRef == null) return 1;
        if (bRef == null) return -1;
        return aRef.compareTo(bRef);
      });

      return todaysTasks;
    });
  }

  // Add a new task
  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    DateTime? startAt,
    DateTime? endAt,
    String? category,
    int priority = 2,
  }) async {
    if (_userId.isEmpty) throw Exception('User not logged in');

    final task = Task(
      id: '', // Will be set by Firestore
      title: title,
      description: description,
      dueDate: dueDate,
      startAt: startAt,
      endAt: endAt,
      isCompleted: false,
      userId: _userId,
      createdAt: DateTime.now(),
      category: category,
      priority: priority,
    );

    final docRef = await _firestore.collection('tasks').add(task.toMap());
    
    // Schedule notification for the task
    print('🔔 Task created with ID: ${docRef.id}, dueDate: $dueDate, endAt: $endAt');
    // Prefer endAt for notification if provided
    final notificationTime = endAt ?? dueDate;
    if (notificationTime != null) {
      try {
        final settings = await _notificationService.loadSettings();
        print('🔔 Notification settings loaded - tasksEnabled: ${settings.tasksEnabled}, reminderMinutes: ${settings.taskReminderMinutes}');
        if (settings.tasksEnabled) {
          final taskWithId = task.copyWith(id: docRef.id);
          print('🔔 Calling scheduleTaskNotification...');
          await _notificationService.scheduleTaskNotification(
            taskWithId.copyWith(dueDate: notificationTime),
            reminderMinutes: settings.taskReminderMinutes,
          );
          print('🔔 Notification scheduling completed');
        } else {
          print('⚠️ Task notifications are disabled in settings');
        }
      } catch (e, stackTrace) {
        print('❌ Error scheduling notification: $e');
        print('Stack trace: $stackTrace');
      }
    } else {
      print('⚠️ No due date set for task, skipping notification');
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
    
    // Update notification
    if (task.dueDate != null && !task.isCompleted) {
      final settings = await _notificationService.loadSettings();
      if (settings.tasksEnabled) {
        await _notificationService.cancelTaskNotification(task.id);
        await _notificationService.scheduleTaskNotification(
          task,
          reminderMinutes: settings.taskReminderMinutes,
        );
      }
    } else {
      // Cancel notification if task is completed or has no due date
      await _notificationService.cancelTaskNotification(task.id);
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': !isCompleted,
      'completedAt': !isCompleted ? DateTime.now().toIso8601String() : null,
    });
    
    // Cancel notification when task is completed
    if (!isCompleted) {
      await _notificationService.cancelTaskNotification(taskId);
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
    // Cancel notification when task is deleted
    await _notificationService.cancelTaskNotification(taskId);
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

  // Get task streak based on completed tasks (real-time stream)
  Stream<int> getTaskStreakStream() async* {
    if (_userId.isEmpty) {
      yield 0;
      return;
    }

    yield* _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .where('isCompleted', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return 0;

      final tasks = snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .where((task) => task.completedAt != null)
          .toList();

      if (tasks.isEmpty) return 0;

      // Get unique completion dates
      final completionDates = tasks
          .map((task) {
            final date = task.completedAt!;
            return DateTime(date.year, date.month, date.day);
          })
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      // Calculate streak
      final now = DateTime.now();
      var checkDate = DateTime(now.year, now.month, now.day);
      int streak = 0;

      for (var i = 0; i < 365; i++) {
        if (completionDates.contains(checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          // Allow grace for today if no tasks completed yet
          if (i == 0 && checkDate == DateTime(now.year, now.month, now.day)) {
            checkDate = checkDate.subtract(const Duration(days: 1));
            continue;
          }
          break;
        }
      }

      return streak;
    });
  }

  // Schedule notifications for all existing tasks (for migration/sync)
  Future<void> rescheduleAllNotifications() async {
    print('🔔 Starting to reschedule notifications for all existing tasks...');
    try {
      final settings = await _notificationService.loadSettings();
      if (!settings.tasksEnabled) {
        print('⚠️ Task notifications are disabled, skipping reschedule');
        return;
      }

      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: _userId)
          .get();

      int scheduledCount = 0;
      int skippedCount = 0;

      for (var doc in snapshot.docs) {
        try {
          final task = Task.fromMap(doc.data(), doc.id);
          
          // Only schedule for incomplete tasks with future due dates
          if (!task.isCompleted && task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
            await _notificationService.cancelTaskNotification(task.id);
            await _notificationService.scheduleTaskNotification(
              task,
              reminderMinutes: settings.taskReminderMinutes,
            );
            scheduledCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          print('❌ Error scheduling notification for task ${doc.id}: $e');
        }
      }

      print('✅ Rescheduled $scheduledCount task notifications');
      print('⏭️ Skipped $skippedCount tasks (completed or past due date)');
    } catch (e, stackTrace) {
      print('❌ Error in rescheduleAllNotifications: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

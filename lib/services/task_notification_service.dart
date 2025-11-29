import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';
import '../models/routine_model.dart';

class TaskNotificationService {
  static const String _settingsKey = 'task_notification_settings';
  static const int _baseTaskNotificationId = 1000;
  static const int _baseRoutineNotificationId = 2000;
  
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> initialize() async {
    print('🔔 Initializing notification service...');
    
    // Initialize timezone data
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka')); // Bangladesh timezone
    print('🔔 Timezone set to: ${tz.local}');

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    // Create Android notification channels
    await _createNotificationChannels();
    print('🔔 Notification service initialized successfully');
  }
  
  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // Task notification channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'tasks',
          'Task Reminders',
          description: 'Notifications for task due dates',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      
      // Task reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'task_reminders',
          'Task Pre-Reminders',
          description: 'Reminder notifications before tasks are due',
          importance: Importance.defaultImportance,
          playSound: false,
          enableVibration: true,
        ),
      );
      
      // Routine notification channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'routines',
          'Routine Reminders',
          description: 'Notifications for routine start times',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      
      // Routine reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'routine_reminders',
          'Routine Pre-Reminders',
          description: 'Reminder notifications before routines start',
          importance: Importance.defaultImportance,
          playSound: false,
          enableVibration: true,
        ),
      );
      
      print('🔔 Created 4 notification channels');
    }
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // You can navigate to specific screens here based on payload
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  // Schedule notification for a task
  Future<void> scheduleTaskNotification(Task task, {int reminderMinutes = 30}) async {
    if (task.dueDate == null || task.isCompleted) {
      print('⚠️ Task notification not scheduled: ${task.dueDate == null ? "No due date" : "Task completed"}');
      return;
    }

    final dueDate = task.dueDate!;
    
    // Don't schedule if due date is in the past
    if (dueDate.isBefore(DateTime.now())) {
      print('⚠️ Task notification not scheduled: Due date is in the past ($dueDate)');
      return;
    }

    print('📅 Scheduling task notification for: ${task.title}');
    print('   Due date: $dueDate');
    print('   Reminder: $reminderMinutes minutes before');

    // Calculate notification ID based on task ID
    final notificationId = _baseTaskNotificationId + task.id.hashCode % 1000;

    // Schedule notification at due date
    await _scheduleNotification(
      id: notificationId,
      title: '📝 Task Due: ${task.title}',
      body: task.description ?? 'Your task is due now!',
      scheduledTime: dueDate,
      payload: 'task_${task.id}',
      channelId: 'tasks',
      channelName: 'Task Reminders',
      priority: _getPriorityLevel(task.priority),
    );

    print('✅ Scheduled main notification (ID: $notificationId)');

    // Schedule reminder notification before due date
    if (reminderMinutes > 0) {
      final reminderTime = dueDate.subtract(Duration(minutes: reminderMinutes));
      
      if (reminderTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: notificationId + 1,
          title: '⏰ Task Reminder: ${task.title}',
          body: 'Due in $reminderMinutes minutes',
          scheduledTime: reminderTime,
          payload: 'task_reminder_${task.id}',
          channelId: 'task_reminders',
          channelName: 'Task Pre-Reminders',
          priority: Priority.defaultPriority,
        );
        print('✅ Scheduled reminder notification (ID: ${notificationId + 1}) at $reminderTime');
      } else {
        print('⚠️ Reminder time is in the past, skipping');
      }
    }
  }

  // Schedule notification for a routine
  Future<void> scheduleRoutineNotification(RoutineItem routine, {int reminderMinutes = 15}) async {
    if (!routine.isActive) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get current day of week (1=Monday, 7=Sunday)
    final currentDayOfWeek = now.weekday;
    
    // Check if routine is scheduled for today
    if (!routine.daysOfWeek.contains(currentDayOfWeek)) {
      return;
    }

    // Calculate notification ID based on routine ID
    final notificationId = _baseRoutineNotificationId + routine.id.hashCode % 1000;

    // Create notification time for today
    final notificationTime = DateTime(
      today.year,
      today.month,
      today.day,
      routine.startTime.hour,
      routine.startTime.minute,
    );

    // Don't schedule if time has passed
    if (notificationTime.isBefore(now)) {
      return;
    }

    // Schedule notification at routine start time
    await _scheduleNotification(
      id: notificationId,
      title: '🔔 Routine: ${routine.title}',
      body: routine.subject != null 
          ? '${routine.subject}${routine.location != null ? " at ${routine.location}" : ""}' 
          : routine.description ?? 'Your routine is starting now',
      scheduledTime: notificationTime,
      payload: 'routine_${routine.id}',
      channelId: 'routines',
      channelName: 'Routine Reminders',
      priority: Priority.high,
    );

    // Schedule reminder notification before routine
    if (reminderMinutes > 0) {
      final reminderTime = notificationTime.subtract(Duration(minutes: reminderMinutes));
      
      if (reminderTime.isAfter(now)) {
        await _scheduleNotification(
          id: notificationId + 1,
          title: '⏰ Routine Starting Soon: ${routine.title}',
          body: 'Starts in $reminderMinutes minutes',
          scheduledTime: reminderTime,
          payload: 'routine_reminder_${routine.id}',
          channelId: 'routine_reminders',
          channelName: 'Routine Pre-Reminders',
          priority: Priority.defaultPriority,
        );
      }
    }
  }

  // Schedule notification for all weekly occurrences of a routine
  Future<void> scheduleWeeklyRoutineNotifications(RoutineItem routine, {int reminderMinutes = 15}) async {
    if (!routine.isActive) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Schedule for each day of the week
    for (int dayOfWeek in routine.daysOfWeek) {
      // Calculate days until this day of week
      int daysUntil = dayOfWeek - now.weekday;
      if (daysUntil < 0) {
        daysUntil += 7; // Next week
      }

      final targetDate = today.add(Duration(days: daysUntil));
      final notificationTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        routine.startTime.hour,
        routine.startTime.minute,
      );

      // Skip if time has already passed today
      if (notificationTime.isBefore(now)) {
        continue;
      }

      // Calculate unique notification ID for this day
      final notificationId = _baseRoutineNotificationId + 
          routine.id.hashCode % 1000 + 
          (dayOfWeek * 10);

      // Schedule notification at routine start time
      await _scheduleNotification(
        id: notificationId,
        title: '🔔 Routine: ${routine.title}',
        body: routine.subject != null 
            ? '${routine.subject}${routine.location != null ? " at ${routine.location}" : ""}' 
            : routine.description ?? 'Your routine is starting now',
        scheduledTime: notificationTime,
        payload: 'routine_${routine.id}_day_$dayOfWeek',
        channelId: 'routines',
        channelName: 'Routine Reminders',
        priority: Priority.high,
      );

      // Schedule reminder
      if (reminderMinutes > 0) {
        final reminderTime = notificationTime.subtract(Duration(minutes: reminderMinutes));
        
        if (reminderTime.isAfter(now)) {
          await _scheduleNotification(
            id: notificationId + 1,
            title: '⏰ Routine Starting Soon: ${routine.title}',
            body: 'Starts in $reminderMinutes minutes',
            scheduledTime: reminderTime,
            payload: 'routine_reminder_${routine.id}_day_$dayOfWeek',
            channelId: 'routine_reminders',
            channelName: 'Routine Pre-Reminders',
            priority: Priority.defaultPriority,
          );
        }
      }
    }
  }

  // Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
    required String channelId,
    required String channelName,
    Priority priority = Priority.high,
  }) async {
    print('🔔 _scheduleNotification called:');
    print('   ID: $id');
    print('   Title: $title');
    print('   Scheduled time: $scheduledTime');
    print('   Current time: ${DateTime.now()}');
    print('   Channel: $channelId');
    
    // Only schedule if time is in the future
    if (scheduledTime.isBefore(DateTime.now())) {
      print('❌ Cannot schedule: time is in the past');
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Notifications for $channelName',
        importance: Importance.high,
        priority: priority,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(body),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert to TZDateTime
      final tzScheduledTime = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );
      
      print('   TZ Scheduled time: $tzScheduledTime');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      
      print('✅ Notification scheduled successfully (ID: $id)');
    } catch (e, stackTrace) {
      print('❌ Error in _scheduleNotification: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get priority level based on task priority
  Priority _getPriorityLevel(int priority) {
    switch (priority) {
      case 3: // High
        return Priority.high;
      case 2: // Medium
        return Priority.defaultPriority;
      case 1: // Low
        return Priority.low;
      default:
        return Priority.defaultPriority;
    }
  }

  // Cancel task notification
  Future<void> cancelTaskNotification(String taskId) async {
    final notificationId = _baseTaskNotificationId + taskId.hashCode % 1000;
    await _notifications.cancel(notificationId);
    await _notifications.cancel(notificationId + 1); // Cancel reminder too
  }

  // Cancel routine notification
  Future<void> cancelRoutineNotification(String routineId) async {
    final baseId = _baseRoutineNotificationId + routineId.hashCode % 1000;
    
    // Cancel all possible day variations
    for (int day = 1; day <= 7; day++) {
      final notificationId = baseId + (day * 10);
      await _notifications.cancel(notificationId);
      await _notifications.cancel(notificationId + 1); // Cancel reminder
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Save notification settings
  Future<void> saveSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // Load notification settings
  Future<NotificationSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        return NotificationSettings.fromJson(jsonDecode(settingsJson));
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    }
    
    return NotificationSettings(); // Return default settings
  }

  // Show immediate test notification
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test',
      'Test Notifications',
      channelDescription: 'Test notification channel',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      99999,
      '✅ Notification Test',
      'Task and routine notifications are working perfectly!',
      details,
    );
  }
}

// Notification Settings Model
class NotificationSettings {
  final bool tasksEnabled;
  final bool routinesEnabled;
  final int taskReminderMinutes;
  final int routineReminderMinutes;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationSettings({
    this.tasksEnabled = true,
    this.routinesEnabled = true,
    this.taskReminderMinutes = 30,
    this.routineReminderMinutes = 15,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationSettings copyWith({
    bool? tasksEnabled,
    bool? routinesEnabled,
    int? taskReminderMinutes,
    int? routineReminderMinutes,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      tasksEnabled: tasksEnabled ?? this.tasksEnabled,
      routinesEnabled: routinesEnabled ?? this.routinesEnabled,
      taskReminderMinutes: taskReminderMinutes ?? this.taskReminderMinutes,
      routineReminderMinutes: routineReminderMinutes ?? this.routineReminderMinutes,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tasksEnabled': tasksEnabled,
      'routinesEnabled': routinesEnabled,
      'taskReminderMinutes': taskReminderMinutes,
      'routineReminderMinutes': routineReminderMinutes,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      tasksEnabled: json['tasksEnabled'] ?? true,
      routinesEnabled: json['routinesEnabled'] ?? true,
      taskReminderMinutes: json['taskReminderMinutes'] ?? 30,
      routineReminderMinutes: json['routineReminderMinutes'] ?? 15,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }
}

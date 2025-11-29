import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_time_model.dart';

class PrayerNotificationService {
  static const String _settingsKey = 'prayer_notification_settings';
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> initialize() async {
    print('🕌 Initializing prayer notification service...');
    
    // Initialize timezone data
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka')); // Bangladesh timezone
    print('🕌 Timezone set to: ${tz.local}');

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
    
    // Create notification channels
    await _createNotificationChannels();
    print('🕌 Prayer notification service initialized successfully');
  }
  
  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // Prayer times notification channel with sound and vibration
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_times',
          'Prayer Times',
          description: 'Notifications for daily prayer times with Adhan',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color(0xFF00FF00),
        ),
      );
      
      // Prayer reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_reminders',
          'Prayer Reminders',
          description: 'Reminder notifications before prayer times',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      
      print('🕌 Created 2 prayer notification channels');
    }
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('🕌 Prayer notification tapped: ${response.payload}');
    print('🕌 Action ID: ${response.actionId}');
    
    if (response.actionId == 'mark_prayed') {
      print('🕌 User marked prayer as completed');
      // You can add logic to mark prayer as completed
    } else if (response.actionId == 'snooze') {
      print('🕌 User snoozed prayer reminder');
      // You can add snooze logic here
    }
    // You can navigate to prayer times screen here
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

    return true; // Default to true for other platforms
  }

  // Schedule all prayer notifications
  Future<void> schedulePrayerNotifications(
    DailyPrayerTimes prayerTimes,
    PrayerNotificationSettings settings,
  ) async {
    // Cancel existing notifications first
    await cancelAllNotifications();

    final prayers = prayerTimes.allPrayers;
    
    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      
      // Check if notifications are enabled for this prayer
      if (!settings.isEnabledFor(prayer.name)) {
        continue;
      }

      // Schedule notification at prayer time
      await _scheduleNotification(
        id: i * 2, // Use even numbers for prayer time notifications
        title: '🕌 ${prayer.arabicName} - ${prayer.name}',
        body: 'It\'s time for ${prayer.name} prayer. May Allah accept your prayers. 🤲',
        scheduledTime: prayer.time,
        payload: prayer.name,
        channelId: 'prayer_times',
        soundEnabled: settings.adhanSoundEnabled,
        vibrateEnabled: settings.vibrateEnabled,
      );

      // Schedule reminder notification before prayer time
      if (settings.reminderMinutes > 0) {
        final reminderTime = prayer.time.subtract(
          Duration(minutes: settings.reminderMinutes),
        );

        // Only schedule if reminder time is in the future
        if (reminderTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: i * 2 + 1, // Use odd numbers for reminder notifications
            title: '⏰ Prayer Reminder',
            body: '${prayer.name} prayer in ${settings.reminderMinutes} minutes. Prepare for prayer.',
            scheduledTime: reminderTime,
            payload: '${prayer.name}_reminder',
            channelId: 'prayer_reminders',
            soundEnabled: true, // Enable sound for reminders
            vibrateEnabled: settings.vibrateEnabled,
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
    bool soundEnabled = true,
    bool vibrateEnabled = true,
  }) async {
    // Only schedule if time is in the future
    if (scheduledTime.isBefore(DateTime.now())) {
      print('⚠️ Skipping past notification: $title at $scheduledTime');
      return;
    }

    print('🕌 Scheduling notification: $title at $scheduledTime');

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'prayer_times' ? 'Prayer Times' : 'Prayer Reminders',
      channelDescription: channelId == 'prayer_times' 
          ? 'Notifications for daily prayer times with Adhan'
          : 'Reminder notifications before prayer times',
      importance: channelId == 'prayer_times' ? Importance.max : Importance.high,
      priority: Priority.high,
      playSound: soundEnabled,
      enableVibration: vibrateEnabled,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
      ),
      // Add action buttons
      actions: channelId == 'prayer_times' ? [
        const AndroidNotificationAction(
          'mark_prayed',
          'Prayed ✓',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          'Remind Later',
          showsUserInterface: false,
        ),
      ] : null,
      ongoing: false,
      autoCancel: false, // Don't auto-cancel when tapped
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: channelId == 'prayer_times', // Full screen for prayer times
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
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
    
    print('✅ Scheduled notification ID: $id for $title');
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific prayer notification
  Future<void> cancelPrayerNotification(String prayerName) async {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final index = prayers.indexOf(prayerName);
    
    if (index != -1) {
      await _notifications.cancel(index * 2); // Prayer time notification
      await _notifications.cancel(index * 2 + 1); // Reminder notification
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Save notification settings
  Future<void> saveSettings(PrayerNotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // Load notification settings
  Future<PrayerNotificationSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        return PrayerNotificationSettings.fromJson(jsonDecode(settingsJson));
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    }
    
    return PrayerNotificationSettings(); // Return default settings
  }

  // Update settings for a specific prayer
  Future<void> updatePrayerSetting(
    String prayerName,
    bool enabled,
  ) async {
    final settings = await loadSettings();
    PrayerNotificationSettings updatedSettings;

    switch (prayerName.toLowerCase()) {
      case 'fajr':
        updatedSettings = settings.copyWith(fajrEnabled: enabled);
        break;
      case 'dhuhr':
        updatedSettings = settings.copyWith(dhuhrEnabled: enabled);
        break;
      case 'asr':
        updatedSettings = settings.copyWith(asrEnabled: enabled);
        break;
      case 'maghrib':
        updatedSettings = settings.copyWith(maghribEnabled: enabled);
        break;
      case 'isha':
        updatedSettings = settings.copyWith(ishaEnabled: enabled);
        break;
      default:
        return;
    }

    await saveSettings(updatedSettings);
  }

  // Show immediate test notification
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_times',
      'Prayer Times',
      channelDescription: 'Notifications for daily prayer times',
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
      999,
      'Prayer Notification Test',
      'Prayer notifications are working correctly!',
      details,
    );
  }
}

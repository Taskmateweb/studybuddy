import 'dart:convert';
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
    // Initialize timezone data
    tz.initializeTimeZones();

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
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
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
        title: '${prayer.arabicName} - ${prayer.name}',
        body: 'It\'s time for ${prayer.name} prayer. May Allah accept your prayers.',
        scheduledTime: prayer.time,
        payload: prayer.name,
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
            title: 'Prayer Reminder',
            body: '${prayer.name} prayer in ${settings.reminderMinutes} minutes',
            scheduledTime: reminderTime,
            payload: '${prayer.name}_reminder',
            soundEnabled: false, // No sound for reminders
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
    bool soundEnabled = true,
    bool vibrateEnabled = true,
  }) async {
    // Only schedule if time is in the future
    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'prayer_times',
      'Prayer Times',
      channelDescription: 'Notifications for daily prayer times',
      importance: Importance.high,
      priority: Priority.high,
      playSound: soundEnabled,
      enableVibration: vibrateEnabled,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(''),
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

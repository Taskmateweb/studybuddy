# Notification Fix Guide

## Problem
Notifications were only working when using the "Test Notification" button, but automatic scheduled notifications for tasks and routines weren't appearing.

## Root Cause
On Android 12+ (API level 31+), apps need **runtime permission** for `SCHEDULE_EXACT_ALARM` to schedule exact-time notifications. The permission was declared in AndroidManifest.xml but wasn't being requested at runtime.

## What Was Fixed

### 1. **Runtime Permission Request** (`task_notification_service.dart`)
- Added `requestExactAlarmsPermission()` call in the `requestPermissions()` method
- Added `canScheduleExactAlarms()` check to verify permission status
- Enhanced permission checking with detailed logging

### 2. **Android Manifest Updates** (`AndroidManifest.xml`)
Added three essential components:

#### a) Boot Completed Permission
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```
This allows notifications to be rescheduled after device reboot.

#### b) Notification Receivers
```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    </intent-filter>
</receiver>
```
These receivers handle scheduled notifications and persist them across reboots.

### 3. **Permission Status UI** (`notification_settings_screen.dart`)
- Added a warning card that appears when exact alarm permission is not granted
- Shows "Grant Permission" button to request permissions
- Card disappears automatically once permission is granted

## How to Test

### Step 1: Uninstall and Reinstall
```bash
flutter clean
flutter pub get
flutter run
```

### Step 2: Grant Permissions

**Important:** The app will open Android Settings - you need to enable the permission there manually.

1. Open the app
2. Go to **Settings → Notification Settings**
3. If you see an orange warning card, tap **"Open Settings"**
4. Read the instructions in the dialog, then tap **"Open Settings"**
5. Android will open the **App Info** page for StudyBuddy
6. Look for **"Alarms & reminders"** (might be under "Advanced" or "Permissions")
7. Tap it and enable **"Allow setting alarms and reminders"**
8. Press back button to return to the app
9. The orange warning card should disappear automatically

**Troubleshooting:** If you don't see "Alarms & reminders":
- Look under "Advanced" or "Additional settings"
- Some phones call it "Schedule exact alarms" or "Allow exact alarm"
- Try searching for "alarm" in the app settings page

### Step 3: Test Task Notifications
1. Create a new task with a due date 2-3 minutes in the future
2. Enable task notifications in settings (if not already enabled)
3. Wait for the notification to appear

### Step 4: Verify Scheduled Notifications
1. In Notification Settings, tap **"View Pending Notifications"**
2. You should see your scheduled notifications listed

## Permissions Required

### Android Manifest Permissions
- ✅ `POST_NOTIFICATIONS` - Send notifications (Android 13+)
- ✅ `SCHEDULE_EXACT_ALARM` - Schedule exact-time alarms
- ✅ `USE_EXACT_ALARM` - Alternative for exact alarms
- ✅ `RECEIVE_BOOT_COMPLETED` - Reschedule after reboot
- ✅ `WAKE_LOCK` - Keep timer running when screen off
- ✅ `VIBRATE` - Vibration for notifications

### Runtime Permissions (Requested Automatically)
- Notification permission (Android 13+)
- Exact alarm permission (Android 12+)

## Common Issues & Solutions

### Issue 1: Notifications Still Not Working
**Solution:** Check if Battery Optimization is restricting the app
1. Go to Android Settings → Apps → StudyBuddy
2. Battery → Unrestricted
3. Notifications → Allow all notifications

### Issue 2: Permission Not Granted After Tapping Button
**Solution:** The button opens Android Settings - you need to enable it there
1. When you tap "Grant Permission", it opens **App info page**
2. Look for **"Alarms & reminders"** option (might be under "Advanced")
3. Tap it and enable **"Allow setting alarms and reminders"**
4. Go back to the app - refresh or reopen notification settings

**Note:** On some devices, this option might be labeled differently:
- "Alarms and reminders"
- "Schedule exact alarms"
- "Allow exact alarm"

If you can't find it, manually go to: **Android Settings → Apps → StudyBuddy → Alarms & reminders**

### Issue 3: Notifications Work Once Then Stop
**Solution:** Disable battery optimization
1. Android Settings → Apps → Special app access
2. Battery optimization → StudyBuddy → Don't optimize

## Technical Details

### Notification Channels
The app uses 4 notification channels:

1. **tasks** - Task due date notifications (High importance)
2. **task_reminders** - Pre-reminders before task due (Default importance)
3. **routines** - Routine start time notifications (High importance)
4. **routine_reminders** - Pre-reminders before routine (Default importance)

### Notification Scheduling
- Uses `zonedSchedule()` with `AndroidScheduleMode.exactAllowWhileIdle`
- Converts DateTime to TZDateTime for timezone handling
- Schedules both main notification and reminder notification

### How It Works
```dart
// 1. Request permissions at startup (main.dart)
await notificationService.initialize();
await notificationService.requestPermissions();

// 2. Schedule when task is created (task_service.dart)
await _notificationService.scheduleTaskNotification(task);

// 3. Android AlarmManager triggers at exact time
// 4. ScheduledNotificationReceiver shows notification
```

## Logs to Check

Enable debug logs to troubleshoot:
```
🔔 Initializing notification service...
🔔 Timezone set to: Asia/Dhaka
🔔 Notification permission granted: true
🔔 Exact alarm permission granted: true
🔔 Can schedule exact alarms: true
📅 Scheduling task notification for: [Task Name]
✅ Scheduled main notification (ID: XXXX)
```

## Additional Notes

- Notifications are timezone-aware (set to Asia/Dhaka by default)
- Notification IDs are generated from task/routine ID hash codes
- Past due dates are automatically skipped
- Completed tasks don't trigger notifications
- All notifications are rescheduled after device reboot

## Support

If notifications still don't work after following this guide:
1. Check device Android version (must be 12+ for exact alarms)
2. Verify battery optimization is disabled
3. Check system notification settings
4. Try rebooting the device
5. Reinstall the app with `flutter clean`

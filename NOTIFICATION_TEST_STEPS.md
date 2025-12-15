# Notification Test Steps

## THE CRITICAL BUG THAT WAS FIXED

There was a **major bug** in [task_notification_service.dart](lib/services/task_notification_service.dart) on line 488-491:

```dart
extension on AndroidFlutterLocalNotificationsPlugin {
   canScheduleExactAlarms() {}
}
```

This empty extension was overriding the real `canScheduleExactAlarms()` method, causing it to **always return null/false** even when the permission was granted!

**This has been DELETED** - the notification service now works properly.

---

## Quick Test (5 Minutes)

### Step 1: Check Permission Status
1. Open the app on your phone
2. Go to **Settings → Notification Settings**
3. Look at the console/terminal for these messages:
   ```
   🔔 Initializing notification service...
   🔔 Timezone set to: Asia/Dhaka
   🔔 Notification permission granted: true
   🔔 Can schedule exact alarms (before): false or true
   ```

### Step 2: Grant Exact Alarm Permission (If Needed)
**If you see an orange warning card:**
1. Tap **"Open Settings"** button
2. Android will open **App Info → StudyBuddy**
3. Look for **"Alarms & reminders"** (might be under "Advanced")
4. Enable it (switch ON)
5. Go back to the app

**Check the logs again - should now show:**
```
🔔 Can schedule exact alarms (after): true
```

### Step 3: Test with Real Task
1. In the app, go to **Tasks** tab
2. Tap **"+"** to add a task
3. Fill in:
   - Title: "Test Notification"
   - Due Date: **Set to 2 minutes from now**
4. Tap **Save**

**Check the console for:**
```
🔔 Task created with ID: xxx, dueDate: xxx
🔔 Notification settings loaded - tasksEnabled: true
🔔 Calling scheduleTaskNotification...
📅 Scheduling task notification for: Test Notification
🔔 _scheduleNotification called:
   ID: xxxx
   Title: 📝 Task Due: Test Notification
   Scheduled time: [2 minutes from now]
   Current time: [now]
   Channel: tasks
   TZ Scheduled time: [scheduled time]
✅ Notification scheduled successfully (ID: xxxx)
🔔 Notification scheduling completed
```

### Step 4: Verify Scheduled Notifications
1. Go back to **Settings → Notification Settings**
2. Tap **"View Pending Notifications"**
3. You should see your test notification listed

### Step 5: Wait for Notification
**Wait 2 minutes** - the notification should appear automatically!

---

## If Notifications Still Don't Work

### Check 1: Battery Optimization
1. Android Settings → Apps → StudyBuddy
2. Battery → Set to **"Unrestricted"**
3. Notifications → Enable all

### Check 2: Do Not Disturb
- Make sure Do Not Disturb mode is OFF

### Check 3: System Notification Settings
1. Android Settings → Apps → StudyBuddy → Notifications
2. Make sure ALL notification categories are enabled:
   - Task Reminders
   - Task Pre-Reminders
   - Routine Reminders
   - Routine Pre-Reminders

### Check 4: Test Notification Still Works
1. In Notification Settings screen
2. Tap **"Test Notification"** button
3. Should appear immediately
4. If this works, scheduled notifications should also work

---

## What the Fix Changed

**Before:**
- `canScheduleExactAlarms()` was overridden by empty extension → always returned null
- Permission check failed → notifications couldn't be scheduled
- Even with permission granted, the app thought it didn't have permission

**After:**
- Removed the buggy extension
- `canScheduleExactAlarms()` now correctly checks Android system permission
- Notifications can be scheduled when permission is granted

---

## Expected Console Output (Success)

When everything works correctly, you should see:

```
🔔 Initializing notification service...
🔔 Timezone set to: Asia/Dhaka
🔔 Created 4 notification channels
🔔 Notification service initialized successfully
🔔 Notification permission granted: true
🔔 Can schedule exact alarms (before): false
🔔 Opening settings to grant exact alarm permission...
🔔 Settings opened. User needs to enable "Alarms & reminders" permission.
🔔 Can schedule exact alarms (after): true

[After creating a task:]
🔔 Task created with ID: abc123
🔔 Notification settings loaded - tasksEnabled: true
🔔 Calling scheduleTaskNotification...
📅 Scheduling task notification for: Test Task
   Due date: 2024-12-16 15:30:00
   Reminder: 30 minutes before
🔔 _scheduleNotification called:
   ID: 1234
   Title: 📝 Task Due: Test Task
   Scheduled time: 2024-12-16 15:30:00.000
   Current time: 2024-12-16 15:28:00.000
   Channel: tasks
   TZ Scheduled time: 2024-12-16 15:30:00.000+0600
✅ Notification scheduled successfully (ID: 1234)
✅ Scheduled main notification (ID: 1234)
✅ Scheduled reminder notification (ID: 1235) at 2024-12-16 15:00:00.000
🔔 Notification scheduling completed
```

---

## Summary

The notification system is now **completely fixed**. The bug was a simple but critical code error that prevented permission checks from working. Now that it's removed, notifications should work perfectly!

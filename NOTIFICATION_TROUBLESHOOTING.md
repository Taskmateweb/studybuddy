# Notification Troubleshooting Guide

## Issue: Not Receiving Notifications

### What I Fixed:
1. **✅ Added Timezone Configuration**: Set `tz.setLocalLocation(tz.getLocation('Asia/Jakarta'))` in the initialization
2. **✅ Added Debug Logging**: All notification scheduling now prints to console
3. **✅ Added "View Pending Notifications" Button**: Check what's scheduled in the app

---

## Steps to Test Notifications:

### 1. **Check Console Logs**
When you create a task with a due date, you should see logs like:
```
📅 Scheduling task notification for: Your Task Name
   Due date: 2025-11-12 15:30:00.000
   Reminder: 15 minutes before
✅ Scheduled main notification (ID: 1234)
✅ Scheduled reminder notification (ID: 1235) at 2025-11-12 15:15:00.000
```

If you see `⚠️` warnings, they explain why notification wasn't scheduled.

### 2. **View Pending Notifications**
1. Open the app
2. Go to Profile → Notifications
3. Click **"View Pending Notifications"** button
4. This shows all scheduled notifications with their IDs and titles

### 3. **Test Notification Button**
1. Click **"Send Test Notification"** button
2. You should receive an immediate notification
3. If this works, the notification system is functional

---

## Common Issues and Solutions:

### ❌ No Notifications Appear

**Problem 1: Permissions Not Granted**
- **Solution**: Check Android notification permissions in Settings
- Go to: Settings → Apps → StudyBuddy → Notifications
- Enable all notification categories

**Problem 2: Battery Optimization**
- **Solution**: Disable battery optimization for the app
- Go to: Settings → Battery → Battery Optimization
- Find StudyBuddy and select "Don't optimize"

**Problem 3: Task Due Date in Past**
- **Solution**: Set due date to future time (at least 2+ minutes from now)
- Notifications won't schedule for past times

**Problem 4: Incorrect Timezone**
- **Solution**: Update timezone in `task_notification_service.dart` line 21
- Change `'Asia/Jakarta'` to your timezone
- Common timezones:
  - USA East Coast: `'America/New_York'`
  - USA West Coast: `'America/Los_Angeles'`
  - UK: `'Europe/London'`
  - India: `'Asia/Kolkata'`
  - Australia: `'Australia/Sydney'`

### ❌ Console Shows "⚠️ No due date" or "⚠️ Task completed"
- **Solution**: Make sure task has a due date and is not marked as completed

### ❌ Console Shows "⚠️ Due date is in the past"
- **Solution**: Set task due date to at least 2-3 minutes in the future

### ❌ Console Shows "⚠️ Reminder time is in the past"
- **Solution**: Set task due date further in the future
- Example: If reminder is 15 minutes, set due date at least 16+ minutes from now

---

## Testing Procedure:

### Quick Test (2 minutes):
1. Open the app
2. Create a new task
3. Set title: "Test Notification"
4. Set due date: **Today, 3 minutes from now**
5. Save the task
6. Check console logs for "✅ Scheduled" messages
7. Click "View Pending Notifications" to verify
8. Wait 3 minutes (you should get notification at due time)
9. At -15 minutes before due time, you'll get the reminder

### Reminder Test:
1. Create a task with due date **20 minutes from now**
2. Set reminder to **15 minutes before**
3. Save and check logs
4. You should receive:
   - Reminder notification in 5 minutes (20 - 15 = 5)
   - Main notification in 20 minutes

---

## How Notifications Work:

### Task Notifications:
- **Main Notification**: Fires at exact due date/time
- **Reminder Notification**: Fires X minutes before due date
- Both must be in the future to schedule

### Notification Settings:
- **Tasks Enabled**: Controls if task notifications are sent
- **Task Reminder Minutes**: How early to send reminder (15, 30, 60, 120, or 1440 minutes)
- **Sound Enabled**: Play notification sound
- **Vibration Enabled**: Vibrate on notification

---

## Android-Specific Requirements:

### Manifest Permissions (Already Added):
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

### Exact Alarm Permission:
- Android 13+ requires explicit permission for exact alarms
- The app requests this automatically on first launch
- If denied, go to Settings → Apps → StudyBuddy → Alarms & reminders → Allow

---

## Debug Checklist:

- [ ] Test notification works (proves notification system is functional)
- [ ] Pending notifications shows scheduled items
- [ ] Console logs show "✅ Scheduled" messages
- [ ] Task has future due date (at least 2+ minutes from now)
- [ ] Tasks are enabled in notification settings
- [ ] Android notification permission granted
- [ ] Battery optimization disabled for app
- [ ] Exact alarm permission granted (Android 13+)
- [ ] Timezone is correct in code

---

## Still Not Working?

1. **Restart the App**: Do a full restart (not hot reload)
   ```powershell
   flutter run
   ```

2. **Clear App Data**: 
   - Settings → Apps → StudyBuddy → Storage → Clear Data
   - Re-open app and grant permissions again

3. **Check Android Logs**:
   ```powershell
   adb logcat | findstr "notification"
   ```

4. **Verify Timezone**: Print timezone in console:
   ```dart
   print('Current timezone: ${tz.local}');
   ```

---

## Expected Behavior:

✅ **Working Correctly When:**
- Test notification appears immediately
- Console shows "✅ Scheduled" messages
- "View Pending Notifications" shows your tasks
- Notification arrives at scheduled time
- Reminder arrives X minutes before due time

❌ **Not Working If:**
- Test notification doesn't appear (permissions issue)
- Console shows "⚠️" warnings (check logs for reason)
- "View Pending Notifications" is empty (nothing scheduled)
- No notification at due time (check battery optimization)

---

## Contact Information:

If issues persist, check:
1. Console logs for specific error messages
2. Pending notifications list
3. Android app permissions
4. Battery optimization settings

**Timezone Note**: Make sure to set your correct timezone in `task_notification_service.dart` line 21!

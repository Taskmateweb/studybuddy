# Quick Notification Test Guide

## Steps to Test Notifications:

### 1. **Check App Initialization Logs**
When the app starts, you should see in console:
```
🔔 Initializing notification service...
🔔 Timezone set to: [timezone info]
🔔 Created 4 notification channels
🔔 Notification service initialized successfully
```

If you DON'T see these logs, the notification service isn't initializing.

---

### 2. **Create a Test Task**
1. Open the app
2. Tap "+" button to add a new task
3. Fill in:
   - **Title**: "Test Notification"
   - **Due Date**: Set to **5 minutes from now** (very important!)
   - **Time**: Set to actual time 5 minutes from now
4. Save the task

---

### 3. **Check Console Logs**
After creating the task, you MUST see these logs:
```
🔔 Task created with ID: [some-id], dueDate: [date]
🔔 Notification settings loaded - tasksEnabled: true, reminderMinutes: 15
🔔 Calling scheduleTaskNotification...
📅 Scheduling task notification for: Test Notification
   Due date: [your date]
   Reminder: 15 minutes before
🔔 _scheduleNotification called:
   ID: 1XXX
   Title: 📝 Task Due: Test Notification
   Scheduled time: [time]
   Current time: [current]
   Channel: tasks
   TZ Scheduled time: [tz time]
✅ Notification scheduled successfully (ID: 1XXX)
✅ Scheduled main notification (ID: 1XXX)
🔔 _scheduleNotification called:
   ...
✅ Scheduled reminder notification (ID: 1XXX)
🔔 Notification scheduling completed
```

---

### 4. **What Each Log Means**

#### ✅ **GOOD LOGS:**
- `🔔 Task created with ID:` - Task was saved to Firestore
- `🔔 Notification settings loaded` - Settings retrieved successfully
- `📅 Scheduling task notification` - About to schedule notification
- `✅ Notification scheduled successfully` - Notification is scheduled!

#### ❌ **BAD LOGS (Problems):**
- `⚠️ No due date set` - You forgot to set a due date
- `⚠️ Task notifications are disabled` - Enable notifications in settings
- `⚠️ Due date is in the past` - Set due date to FUTURE time
- `❌ Cannot schedule: time is in the past` - Time must be in future
- `❌ Error scheduling notification` - Something went wrong (check error)

---

### 5. **Test the Test Notification Button**
1. Go to Profile → Notifications
2. Scroll down
3. Tap **"Send Test Notification"**
4. You should get a notification IMMEDIATELY

**If test notification works:**
- ✅ Notification system is working
- ✅ Permissions are granted
- ✅ Problem is with task scheduling logic

**If test notification DOESN'T work:**
- ❌ Android permissions not granted
- ❌ Battery optimization blocking notifications
- ❌ Notification channels not created

---

### 6. **View Pending Notifications**
1. Go to Profile → Notifications
2. Tap **"View Pending Notifications"**
3. You should see your scheduled task notification

**Expected:**
- List showing your task with notification ID
- Title: "📝 Task Due: Test Notification"

**If list is empty:**
- Notifications weren't scheduled (check console logs for why)

---

### 7. **Common Issues and Solutions**

#### Issue: No console logs at all
**Solution:** 
- Make sure app is running with `flutter run`
- Check the PowerShell terminal for logs
- Look for lines starting with 🔔, 📅, ✅, or ❌

#### Issue: "Task notifications are disabled in settings"
**Solution:**
1. Go to Profile → Notifications
2. Toggle **"Enable Task Notifications"** to ON
3. Make sure it's green/enabled

#### Issue: "Due date is in the past"
**Solution:**
- Due date must be in the FUTURE
- Set it to at least 3-5 minutes from current time
- Make sure you set BOTH date AND time

#### Issue: Test notification doesn't appear
**Solution (Android):**
1. Open Android Settings
2. Apps → StudyBuddy → Notifications
3. Make sure "Allow notifications" is ON
4. Check all notification categories are enabled:
   - Task Reminders
   - Task Pre-Reminders
   - Routine Reminders
   - Routine Pre-Reminders

#### Issue: No notification at scheduled time
**Solution (Android Battery):**
1. Open Android Settings
2. Battery → Battery Optimization
3. Find StudyBuddy
4. Select "Don't optimize"
5. Also check: Settings → Apps → StudyBuddy → Battery
6. Select "Unrestricted"

---

### 8. **Expected Timeline (Example)**

If you create a task at **3:00 PM** with:
- Due date: **3:05 PM** (5 minutes later)
- Reminder: **15 minutes before**

**What should happen:**
- ❌ **NO reminder** (because 15 minutes before 3:05 is 2:50, which is in the past)
- ✅ **Main notification at 3:05 PM** - "📝 Task Due: Test Notification"

**Better test:** Create task at **3:00 PM** with:
- Due date: **3:20 PM** (20 minutes later)
- Reminder: **15 minutes before**

**What should happen:**
- ✅ **Reminder at 3:05 PM** (20 - 15 = 5 minutes) - "⏰ Task Reminder: Test Notification"
- ✅ **Main notification at 3:20 PM** - "📝 Task Due: Test Notification"

---

### 9. **Full Test Checklist**

- [ ] App starts and shows initialization logs
- [ ] Created test task with future due date (20+ minutes)
- [ ] Console shows "✅ Notification scheduled successfully"
- [ ] "View Pending Notifications" shows the task
- [ ] Test notification button works
- [ ] Task notifications enabled in settings
- [ ] Android notification permissions granted
- [ ] Battery optimization disabled for app
- [ ] Waiting for scheduled time to see notification

---

### 10. **If Still Not Working**

**Share these details:**
1. All console logs when creating a task
2. Screenshot of "View Pending Notifications" dialog
3. Android version (Settings → About Phone)
4. What happens with test notification button
5. Your timezone
6. The exact due date/time you set

**Timezone Fix:**
If you're NOT in Jakarta timezone, edit this file:
`lib/services/task_notification_service.dart` line ~21

Change:
```dart
tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
```

To your timezone. Common ones:
- USA: `'America/New_York'` or `'America/Los_Angeles'`
- UK: `'Europe/London'`
- India: `'Asia/Kolkata'`
- Australia: `'Australia/Sydney'`

---

## Quick Debug Commands

**View logs in real-time:**
```powershell
# In the terminal where flutter run is running
# Logs will appear automatically
```

**Check pending notifications:**
```powershell
adb shell dumpsys notification | findstr "com.example.studybuddy"
```

**Check app permissions:**
```powershell
adb shell dumpsys package com.example.studybuddy | findstr "permission"
```

---

## Success Criteria

✅ **Notifications are working when:**
1. Test notification appears immediately
2. Console shows "✅ Notification scheduled successfully"
3. "View Pending Notifications" shows your tasks
4. Notification appears at exact scheduled time
5. Reminder appears X minutes before

🎉 **You're done!**

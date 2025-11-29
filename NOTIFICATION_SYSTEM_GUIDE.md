# Task & Routine Notification System

## 🔔 Overview
Comprehensive notification system for StudyBuddy that sends timely reminders for both tasks and routines, helping users stay on track with their schedules.

## ✨ Features Implemented

### 📝 **Task Notifications**
- ✅ Notification at task due time
- ✅ Pre-reminder notifications (15min, 30min, 1hr, 2hr, or 1 day before)
- ✅ Priority-based notification importance (High/Medium/Low)
- ✅ Automatic cancellation when task is completed or deleted
- ✅ Individual notification management per task

### 🔄 **Routine Notifications**
- ✅ Notification at routine start time
- ✅ Pre-reminder notifications (5, 10, 15, 30, or 60 minutes before)
- ✅ Weekly scheduling for all routine days
- ✅ Automatic rescheduling when routine is updated
- ✅ Cancellation when routine is deactivated or deleted

### ⚙️ **Settings & Customization**
- ✅ Enable/disable task notifications globally
- ✅ Enable/disable routine notifications globally
- ✅ Customizable reminder times for tasks
- ✅ Customizable reminder times for routines
- ✅ Sound toggle (on/off)
- ✅ Vibration toggle (on/off)
- ✅ Test notification feature
- ✅ Persistent settings (saved locally)

## 🏗️ Architecture

### **Files Created**

```
lib/
├── services/
│   └── task_notification_service.dart    # Unified notification service
└── screens/
    └── notification_settings_screen.dart # Settings UI
```

### **Files Modified**

```
lib/
├── main.dart                    # Added notification initialization & route
├── services/
│   ├── task_service.dart        # Integrated notifications for tasks
│   └── routine_service.dart     # Integrated notifications for routines
```

## 🚀 How It Works

### **Task Notifications**
1. **When task is created**: Notification is automatically scheduled for due date
2. **Pre-reminder**: Additional notification sent X minutes before due date
3. **On completion**: Both notifications are cancelled
4. **On update**: Notifications are rescheduled with new due date
5. **On deletion**: All related notifications are cancelled

### **Routine Notifications**
1. **When routine is created**: Weekly notifications scheduled for all selected days
2. **Pre-reminder**: Additional notification sent X minutes before each routine
3. **On deactivation**: All notifications are cancelled
4. **On update**: Notifications are rescheduled with new times/days
5. **On deletion**: All related notifications are cancelled

### **Notification IDs**
- **Tasks**: Base ID `1000` + task ID hash
- **Routines**: Base ID `2000` + routine ID hash + (day * 10)
- **Reminders**: Notification ID + 1

This ensures no ID collisions and easy management.

## 📱 User Interface

### **Notification Settings Screen**
Accessible via: Dashboard → Profile → Notification Settings (or add a navigation button)

**Sections:**
1. **Header Card**: Overview with notification icon
2. **Task Notifications**: 
   - Toggle to enable/disable
   - Reminder time selection (chips)
3. **Routine Notifications**:
   - Toggle to enable/disable
   - Reminder time selection (chips)
4. **General Settings**:
   - Sound toggle
   - Vibration toggle
5. **Test Button**: Send test notification

### **Color Scheme**
- **Task Section**: Purple (`#667EEA`)
- **Routine Section**: Green (`#10B981`)
- **General Section**: Orange/Gold (`#F59E0B`)

## 🔧 Technical Implementation

### **Notification Channels**

1. **Tasks** (`tasks`):
   - High priority
   - Sound enabled (if setting allows)
   - Vibration enabled (if setting allows)
   - Shows task title and description

2. **Task Pre-Reminders** (`task_reminders`):
   - Default priority
   - No sound
   - Vibration enabled (if setting allows)
   - Shows time until due

3. **Routines** (`routines`):
   - High priority
   - Sound enabled (if setting allows)
   - Vibration enabled (if setting allows)
   - Shows routine title, subject, and location

4. **Routine Pre-Reminders** (`routine_reminders`):
   - Default priority
   - No sound
   - Vibration enabled (if setting allows)
   - Shows time until start

### **Data Persistence**
- **SharedPreferences** stores:
  - tasksEnabled (bool)
  - routinesEnabled (bool)
  - taskReminderMinutes (int)
  - routineReminderMinutes (int)
  - soundEnabled (bool)
  - vibrationEnabled (bool)

### **Permissions Required**
Already configured in AndroidManifest.xml and Info.plist:
- ✅ `POST_NOTIFICATIONS` (Android 13+)
- ✅ `SCHEDULE_EXACT_ALARM` (Android 12+)
- ✅ `USE_EXACT_ALARM` (Android 12+)

## 💡 Usage Examples

### **For Users**

1. **Enable Task Notifications**:
   ```
   Open Settings → Enable Task Reminders → Select reminder time (e.g., 30 min)
   ```

2. **Enable Routine Notifications**:
   ```
   Open Settings → Enable Routine Reminders → Select reminder time (e.g., 15 min)
   ```

3. **Test Notifications**:
   ```
   Open Settings → Tap "Send Test Notification"
   ```

### **For Developers**

1. **Schedule Task Notification**:
   ```dart
   await taskService.addTask(
     title: 'Complete Assignment',
     dueDate: DateTime.now().add(Duration(hours: 2)),
     priority: 3, // High priority
   );
   // Notification automatically scheduled!
   ```

2. **Schedule Routine Notification**:
   ```dart
   await routineService.addRoutine(
     title: 'Math Class',
     startTime: DateTime(2024, 1, 1, 9, 0), // 9:00 AM
     endTime: DateTime(2024, 1, 1, 10, 30), // 10:30 AM
     daysOfWeek: [1, 3, 5], // Mon, Wed, Fri
   );
   // Weekly notifications automatically scheduled!
   ```

3. **Customize Notification Settings**:
   ```dart
   final service = TaskNotificationService();
   final settings = NotificationSettings(
     tasksEnabled: true,
     routinesEnabled: true,
     taskReminderMinutes: 60, // 1 hour before
     routineReminderMinutes: 15, // 15 minutes before
     soundEnabled: true,
     vibrationEnabled: true,
   );
   await service.saveSettings(settings);
   ```

## 🎨 Notification Format

### **Task Due Notification**
```
Title: 📝 Task Due: Complete Assignment
Body: Finish the math homework for tomorrow
```

### **Task Reminder**
```
Title: ⏰ Task Reminder: Complete Assignment
Body: Due in 30 minutes
```

### **Routine Notification**
```
Title: 🔔 Routine: Math Class
Body: Mathematics at Room 301
```

### **Routine Reminder**
```
Title: ⏰ Routine Starting Soon: Math Class
Body: Starts in 15 minutes
```

## ⚠️ Important Notes

### **Android Battery Optimization**
- Some Android devices may restrict background notifications
- Users should whitelist the app in battery settings
- Notifications use `exactAllowWhileIdle` mode for reliability

### **Notification Timing**
- All notifications use device local timezone
- Past notifications are not scheduled
- Weekly routines are scheduled up to 7 days in advance

### **Notification Limits**
- Maximum ~1000 unique task notifications
- Maximum ~700 unique routine notifications (7 days × 100 routines)
- Old notifications are cancelled when new ones are scheduled

## 🐛 Troubleshooting

### **Notifications not appearing**
1. Check notification permissions in device settings
2. Ensure the app is not in battery saver mode
3. Use "Test Notification" to verify functionality
4. Check that notifications are enabled in settings

### **Wrong notification time**
1. Verify device timezone is correct
2. Check task due date/routine start time
3. Ensure reminder minutes setting is correct

### **Notifications not cancelled**
1. Notifications auto-cancel when tasks are completed
2. Routine notifications cancel when routine is deactivated
3. Use manual cancellation if needed

## 🔮 Future Enhancements

- [ ] Notification history
- [ ] Snooze functionality
- [ ] Custom notification sounds per category
- [ ] Notification grouping (batch notifications)
- [ ] Smart reminder timing (based on user behavior)
- [ ] Recurring task notifications
- [ ] Location-based reminders
- [ ] Widget with notification preview
- [ ] Notification actions (complete task from notification)
- [ ] Daily summary notification

## 🎯 Goal Achieved

✅ **Never Miss Important Tasks**: Timely reminders keep users on track
✅ **Stay Prepared for Routines**: Pre-notifications help users prepare
✅ **Customizable Experience**: Users control exactly when and how they're notified
✅ **Reliable & Persistent**: Notifications survive app restarts and device reboots
✅ **Clean & Organized**: Separate channels for different notification types
✅ **Battery Efficient**: Uses exact alarms only when necessary

---

**"Success is the sum of small efforts repeated day in and day out." - Robert Collier**

Stay organized, stay notified, stay successful! 🎓✨

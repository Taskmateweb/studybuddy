# Balance Your Life – Prayer Time Integration

## 🕌 Overview
The "Balance Your Life" feature helps Muslim users maintain a balanced routine by staying mindful of daily prayer times. It displays accurate real-time prayer schedules and allows users to enable prayer time notifications directly from the app.

## ✨ Features Implemented

### 📿 **Prayer Time Display**
- ✅ Shows all 5 daily prayers: Fajr, Dhuhr, Asr, Maghrib, Isha
- ✅ Additional times: Sunrise and Midnight
- ✅ Beautiful Islamic-themed UI with soft greens, blues, and gold accents
- ✅ Prayer icons (🌅 🌞 🌤️ 🌆 🌙)
- ✅ Arabic names alongside English (الفجر, الظهر, العصر, المغرب, العشاء)

### ⏰ **Next Prayer Countdown**
- ✅ Highlights the next upcoming prayer with visual emphasis
- ✅ Live countdown timer showing time remaining (HH:MM:SS)
- ✅ Pulsing animation effect on next prayer card
- ✅ Completed prayers shown in muted colors

### 🔔 **Smart Notifications**
- ✅ Individual toggle for each prayer notification
- ✅ Customizable reminder time (5, 10, 15, 20, 30 minutes before)
- ✅ Adhan sound option (toggle on/off)
- ✅ Vibration setting
- ✅ Notifications persist after app restart
- ✅ Local notifications (no internet required)

### 📍 **Location-Based Calculation**
- ✅ Automatic location detection
- ✅ Uses GPS to determine prayer times accurately
- ✅ Caches location data for offline use
- ✅ Graceful fallback to cached data

### 💾 **Smart Caching**
- ✅ Daily prayer times cached locally
- ✅ Reduces API calls and improves performance
- ✅ Auto-refresh when new day begins
- ✅ Works offline with cached data

### 🌟 **Motivational Content**
- ✅ Rotating Islamic quotes and Hadiths
- ✅ Encourages spiritual balance
- ✅ Beautiful gold-accented quote cards

## 🏗️ Architecture

### **Files Created**

```
lib/
├── models/
│   └── prayer_time_model.dart           # Data models for prayer times
├── services/
│   ├── prayer_service.dart              # Prayer time calculation & caching
│   └── prayer_notification_service.dart # Notification scheduling
└── screens/
    ├── balance_your_life_screen.dart    # Main prayer times UI
    └── prayer_settings_screen.dart      # Notification settings
```

### **Dependencies Added**

```yaml
adhan: ^2.0.0                 # Islamic prayer time calculation
geolocator: ^11.0.0           # Location services
permission_handler: ^11.3.0   # Permission management
timezone: ^0.9.2               # Timezone handling
```

## 📱 User Interface

### **Main Screen**
- **Header**: Modern gradient (green to teal) with mosque icon
- **Quote Card**: Gold-accented motivational quotes
- **Next Prayer Card**: 
  - Pulsing green gradient background
  - Large prayer name and Arabic text
  - Live countdown timer
  - Prayer time display
- **Prayer List**: White card with all prayer times
  - Next prayer highlighted in green
  - Passed prayers shown in gray
  - Each prayer has emoji icon and time

### **Settings Screen**
- **Notification Permission Card**: Green gradient banner
- **Prayer Toggles**: Individual switches for each prayer
- **Reminder Settings**: Chip selector for reminder minutes
- **Sound & Vibration**: Toggle switches
- **Test Notification**: Blue button to test notifications

## 🔧 Technical Implementation

### **Prayer Time Calculation**
Uses the `adhan` package which follows authentic Islamic calculation methods:
- **Calculation Method**: Muslim World League (default)
- **Madhab**: Shafi (configurable)
- **Accurate**: Based on astronomical calculations
- **Timezone-aware**: Handles daylight savings automatically

### **Location Detection**
1. Checks if location services are enabled
2. Requests location permission
3. Gets current GPS coordinates
4. Caches location for future use
5. Falls back to cached location if GPS unavailable

### **Notification Scheduling**
1. Calculates prayer times for the day
2. Checks user preferences for each prayer
3. Schedules notifications at prayer time
4. Schedules reminder notifications (X minutes before)
5. Uses `flutter_local_notifications` for reliability
6. Handles timezone conversions properly

### **Data Persistence**
- **SharedPreferences** for:
  - Cached prayer times (JSON)
  - Saved location data
  - Notification settings
  - User preferences

## 🚀 How to Use

### **For Users**

1. **Access the Feature**:
   - Open StudyBuddy app
   - Tap "Balance Your Life" card on dashboard
   - Tap "Prayer Time ☪️" button

2. **View Prayer Times**:
   - See all 5 daily prayers with times
   - Next prayer highlighted in green
   - Live countdown to next prayer

3. **Enable Notifications**:
   - Tap settings icon (⚙️) in top right
   - Toggle notifications for each prayer
   - Select reminder time (e.g., 10 minutes before)
   - Enable/disable Adhan sound
   - Test notification to verify

4. **Refresh**:
   - Tap refresh icon (🔄) to update prayer times
   - Auto-refreshes when new day begins

### **For Developers**

1. **Install Dependencies**:
```bash
flutter pub get
```

2. **Add Android Permissions** (already configured):
```xml
<!-- In android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

3. **Add iOS Permissions** (already configured):
```xml
<!-- In ios/Runner/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to calculate accurate prayer times</string>
```

4. **Initialize Services**:
```dart
// Already done in BalanceYourLifeScreen
final prayerService = PrayerService();
final notificationService = PrayerNotificationService();

await notificationService.initialize();
final times = await prayerService.getTodayPrayerTimes();
```

## 🎨 Design Guidelines

### **Color Palette**
- **Primary Green**: `#10B981` (Trust, Growth, Peace)
- **Dark Green**: `#059669` (Depth)
- **Blue**: `#3B82F6` (Serenity)
- **Gold**: `#F59E0B` (Spiritual)
- **White**: Background and cards
- **Gray**: Passed prayers

### **Typography**
- **Headers**: Bold, 20-24px
- **Prayer Names**: Bold, 18px
- **Arabic Text**: 14-18px
- **Times**: Bold, 16-20px
- **Body Text**: Regular, 14px

### **Spacing**
- Card margins: 20px
- Internal padding: 20px
- Icon size: 24-32px
- Border radius: 12-20px

## 🔔 Notification System

### **Notification Types**

1. **Prayer Time Notification**:
   - Title: "الفجر - Fajr"
   - Body: "It's time for Fajr prayer. May Allah accept your prayers."
   - Channel: "prayer_times"
   - Priority: High
   - Sound: Optional Adhan
   - Vibration: Optional

2. **Reminder Notification**:
   - Title: "Prayer Reminder"
   - Body: "Fajr prayer in 10 minutes"
   - Channel: "prayer_times"
   - Priority: High
   - Sound: None (silent reminder)
   - Vibration: Optional

### **Notification Channels**
- **Channel ID**: `prayer_times`
- **Channel Name**: Prayer Times
- **Importance**: High
- **Description**: Notifications for daily prayer times

## 📊 Data Models

### **PrayerTime**
```dart
{
  name: String,           // "Fajr"
  arabicName: String,     // "الفجر"
  time: DateTime,         // Exact time
  isNext: bool,           // Is this the next prayer?
  icon: String,           // "🌅"
}
```

### **DailyPrayerTimes**
```dart
{
  date: DateTime,
  fajr: PrayerTime,
  sunrise: PrayerTime,
  dhuhr: PrayerTime,
  asr: PrayerTime,
  maghrib: PrayerTime,
  isha: PrayerTime,
  midnight: PrayerTime?,
  location: String,
}
```

### **PrayerNotificationSettings**
```dart
{
  fajrEnabled: bool,
  dhuhrEnabled: bool,
  asrEnabled: bool,
  maghribEnabled: bool,
  ishaEnabled: bool,
  reminderMinutes: int,
  adhanSoundEnabled: bool,
  vibrateEnabled: bool,
}
```

## ⚠️ Important Notes

### **Location Permission**
- App requests permission on first use
- User can deny and use manual location later (future enhancement)
- Location is cached and reused
- Works offline with cached location

### **Notification Permission**
- Android 13+ requires explicit notification permission
- App requests permission in settings screen
- Test button helps verify notifications are working
- Users can manage permissions in system settings

### **Timezone Handling**
- Uses device timezone automatically
- Handles daylight savings correctly
- Prayer times adjust based on location

### **Battery Optimization**
- Android may limit exact alarms in battery saver mode
- Recommend users whitelist the app
- Notifications use `exactAllowWhileIdle` mode

## 🐛 Troubleshooting

### **Prayer times not showing**
- Check location permission
- Ensure GPS is enabled
- Check internet connection (first time)
- Try refresh button

### **Notifications not working**
- Check notification permission
- Disable battery optimization for app
- Test with "Send Test Notification" button
- Verify Do Not Disturb is off

### **Wrong prayer times**
- Verify location is correct
- Check device timezone settings
- Try refreshing prayer times
- Ensure date/time is correct

### **Location error**
- Enable location services
- Grant location permission
- Check GPS signal
- Try manual location (future feature)

## 🔮 Future Enhancements

- [ ] Qibla direction compass
- [ ] Manual location entry
- [ ] Multiple calculation method options
- [ ] Hijri calendar integration
- [ ] Prayer tracking/statistics
- [ ] Custom Adhan sounds
- [ ] Widget for home screen
- [ ] Apple Watch/Android Wear support
- [ ] Mosque finder nearby
- [ ] Ramadan special features

## 📖 Islamic References

### **Calculation Methods Supported**
- Muslim World League (default)
- Islamic Society of North America (ISNA)
- Egyptian General Authority of Survey
- Umm Al-Qura University, Makkah
- University of Islamic Sciences, Karachi

### **Madhab Options**
- Shafi (default): Earlier Asr time
- Hanafi: Later Asr time

### **Quotes Sources**
- Quran verses
- Authentic Hadiths
- Islamic wisdom

## 🎯 Goal Achieved

✅ **Spiritual Balance**: Helps users maintain prayer times while studying
✅ **Mindfulness**: Gentle reminders without disruption
✅ **Accuracy**: Location-based authentic calculation
✅ **Beautiful UX**: Peaceful, Islamic-themed design
✅ **Reliable**: Works offline with smart caching
✅ **Customizable**: User controls all notification settings

---

**"Verily, prayer restrains from shameful and unjust deeds." - Quran 29:45**

May this feature help users balance their worldly pursuits with spiritual growth. 🤲

import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_notification_service.dart';

class PrayerSettingsScreen extends StatefulWidget {
  final DailyPrayerTimes prayerTimes;
  final VoidCallback onSettingsChanged;

  const PrayerSettingsScreen({
    super.key,
    required this.prayerTimes,
    required this.onSettingsChanged,
  });

  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen> {
  final PrayerNotificationService _notificationService = PrayerNotificationService();
  
  late PrayerNotificationSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.loadSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _notificationService.saveSettings(_settings);
    await _notificationService.schedulePrayerNotifications(widget.prayerTimes, _settings);
    widget.onSettingsChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Prayer Notification Settings'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationPermissionCard(),
                  _buildPrayerToggles(),
                  _buildReminderSettings(),
                  _buildSoundSettings(),
                  _buildTestNotificationButton(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationPermissionCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981),
            const Color(0xFF059669),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Mindful',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Receive timely prayer reminders',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerToggles() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.mosque_rounded,
                  color: const Color(0xFF10B981),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Enable Notifications For',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildPrayerToggle('Fajr', '🌅', _settings.fajrEnabled, (value) {
            setState(() {
              _settings = _settings.copyWith(fajrEnabled: value);
            });
            _saveSettings();
          }),
          _buildPrayerToggle('Dhuhr', '🌞', _settings.dhuhrEnabled, (value) {
            setState(() {
              _settings = _settings.copyWith(dhuhrEnabled: value);
            });
            _saveSettings();
          }),
          _buildPrayerToggle('Asr', '🌤️', _settings.asrEnabled, (value) {
            setState(() {
              _settings = _settings.copyWith(asrEnabled: value);
            });
            _saveSettings();
          }),
          _buildPrayerToggle('Maghrib', '🌆', _settings.maghribEnabled, (value) {
            setState(() {
              _settings = _settings.copyWith(maghribEnabled: value);
            });
            _saveSettings();
          }),
          _buildPrayerToggle('Isha', '🌙', _settings.ishaEnabled, (value) {
            setState(() {
              _settings = _settings.copyWith(ishaEnabled: value);
            });
            _saveSettings();
          }),
        ],
      ),
    );
  }

  Widget _buildPrayerToggle(String name, String icon, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: value 
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: value ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_rounded,
                color: const Color(0xFF3B82F6),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Reminder Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Get notified before prayer time',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [5, 10, 15, 20, 30].map((minutes) {
              final isSelected = _settings.reminderMinutes == minutes;
              return ActionChip(
                label: Text('$minutes min'),
                onPressed: () {
                  setState(() {
                    _settings = _settings.copyWith(reminderMinutes: minutes);
                  });
                  _saveSettings();
                },
                backgroundColor: isSelected 
                    ? const Color(0xFF3B82F6)
                    : Colors.grey.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected 
                      ? const Color(0xFF3B82F6)
                      : Colors.transparent,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.volume_up_rounded,
                  color: const Color(0xFFF59E0B),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sound & Vibration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text(
              'Adhan Sound',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Play adhan at prayer time',
              style: TextStyle(fontSize: 13),
            ),
            secondary: Icon(
              Icons.music_note_rounded,
              color: const Color(0xFFF59E0B),
            ),
            value: _settings.adhanSoundEnabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(adhanSoundEnabled: value);
              });
              _saveSettings();
            },
            activeColor: const Color(0xFF10B981),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text(
              'Vibration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Vibrate on notification',
              style: TextStyle(fontSize: 13),
            ),
            secondary: Icon(
              Icons.vibration_rounded,
              color: const Color(0xFFF59E0B),
            ),
            value: _settings.vibrateEnabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(vibrateEnabled: value);
              });
              _saveSettings();
            },
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await _notificationService.showTestNotification();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Test notification sent!'),
                  ],
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.send_rounded),
        label: const Text(
          'Send Test Notification',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

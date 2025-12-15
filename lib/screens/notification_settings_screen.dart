import 'package:flutter/material.dart';
import '../services/task_notification_service.dart';
import '../services/task_service.dart';
import '../services/routine_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final TaskNotificationService _notificationService = TaskNotificationService();
  final TaskService _taskService = TaskService();
  final RoutineService _routineService = RoutineService();
  
  late NotificationSettings _settings;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  _buildTaskNotifications(),
                  _buildRoutineNotifications(),
                  _buildGeneralSettings(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
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
                      'Stay On Track',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Never miss a task or routine',
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
        ),
        _buildPermissionStatusCard(),
      ],
    );
  }

  Widget _buildPermissionStatusCard() {
    // Permission is handled via AndroidManifest, no warning needed
    return const SizedBox.shrink();
  }

  Widget _buildTaskNotifications() {
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
                const Icon(
                  Icons.task_alt_rounded,
                  color: Color(0xFF667EEA),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Task Notifications',
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
              'Enable Task Reminders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Get notified when tasks are due',
              style: TextStyle(fontSize: 13),
            ),
            secondary: Icon(
              Icons.notifications_rounded,
              color: _settings.tasksEnabled 
                  ? const Color(0xFF667EEA)
                  : Colors.grey.shade400,
            ),
            value: _settings.tasksEnabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(tasksEnabled: value);
              });
              _saveSettings();
            },
            activeThumbColor: const Color(0xFF667EEA),
          ),
          if (_settings.tasksEnabled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_rounded,
                        color: Color(0xFF667EEA),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reminder Time Before Due',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [15, 30, 60, 120, 1440].map((minutes) {
                      final isSelected = _settings.taskReminderMinutes == minutes;
                      String label;
                      if (minutes < 60) {
                        label = '$minutes min';
                      } else if (minutes == 60) {
                        label = '1 hour';
                      } else if (minutes < 1440) {
                        label = '${minutes ~/ 60} hours';
                      } else {
                        label = '1 day';
                      }
                      
                      return ActionChip(
                        label: Text(label),
                        onPressed: () {
                          setState(() {
                            _settings = _settings.copyWith(taskReminderMinutes: minutes);
                          });
                          _saveSettings();
                        },
                        backgroundColor: isSelected 
                            ? const Color(0xFF667EEA)
                            : Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected 
                              ? const Color(0xFF667EEA)
                              : Colors.transparent,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoutineNotifications() {
    return Container(
      margin: const EdgeInsets.all(20),
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
                const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Routine Notifications',
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
              'Enable Routine Reminders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Get notified before routines start',
              style: TextStyle(fontSize: 13),
            ),
            secondary: Icon(
              Icons.alarm_rounded,
              color: _settings.routinesEnabled 
                  ? const Color(0xFF10B981)
                  : Colors.grey.shade400,
            ),
            value: _settings.routinesEnabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(routinesEnabled: value);
              });
              _saveSettings();
            },
            activeThumbColor: const Color(0xFF10B981),
          ),
          if (_settings.routinesEnabled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notify Before Start Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [5, 10, 15, 30, 60].map((minutes) {
                      final isSelected = _settings.routineReminderMinutes == minutes;
                      final label = '$minutes min';
                      
                      return ActionChip(
                        label: Text(label),
                        onPressed: () {
                          setState(() {
                            _settings = _settings.copyWith(routineReminderMinutes: minutes);
                          });
                          _saveSettings();
                        },
                        backgroundColor: isSelected 
                            ? const Color(0xFF10B981)
                            : Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected 
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
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
                const Icon(
                  Icons.settings_rounded,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'General Settings',
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
              'Sound',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Play sound with notifications',
              style: TextStyle(fontSize: 13),
            ),
            secondary: const Icon(
              Icons.volume_up_rounded,
              color: Color(0xFFF59E0B),
            ),
            value: _settings.soundEnabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(soundEnabled: value);
              });
              _saveSettings();
            },
            activeThumbColor: const Color(0xFFF59E0B),
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
            secondary: const Icon(
              Icons.vibration_rounded,
              color: Color(0xFFF59E0B),
            ),
            value: _settings.vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(vibrationEnabled: value);
              });
              _saveSettings();
            },
            activeThumbColor: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  // Removed: _buildTestButton, _buildPendingNotificationsButton, _buildRescheduleButton
  // These debug buttons are no longer needed
}

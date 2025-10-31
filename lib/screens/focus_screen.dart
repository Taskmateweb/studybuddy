import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../services/focus_service.dart';
import '../services/task_service.dart';
import '../models/task_model.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({Key? key}) : super(key: key);

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 25 minutes default
  bool _isRunning = false;
  bool _isPaused = false;
  int _completedPomodoros = 0;
  String? _activeSessionId;
  bool _isScreenLocked = false;
  
  // Settings
  int _focusMinutes = 25;
  
  Task? _selectedTask;
  final TextEditingController _customTimeController = TextEditingController();
  
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _customTimeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_isRunning && _isScreenLocked) {
      // Show unlock dialog
      return await _showUnlockDialog() ?? false;
    }
    return true;
  }

  Future<bool?> _showUnlockDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.red),
              SizedBox(width: 8),
              Text('Focus Mode Locked'),
            ],
          ),
          content: const Text(
            'Are you sure you want to exit Focus Mode? This will end your current session.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay Focused'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isScreenLocked = false;
                });
                _resetTimer();
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer() {
    if (_activeSessionId == null) {
      _createNewSession();
    }
    
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isScreenLocked = true; // Lock screen when timer starts
    });
    
    _rotationController.repeat();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _handlePhaseComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _rotationController.stop();
    setState(() {
      _isRunning = false;
      _isPaused = true;
      _isScreenLocked = false; // Unlock when paused
    });
    
    if (_activeSessionId != null) {
      FocusService().updateSessionStatus(_activeSessionId!, 'paused');
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _rotationController.reset();
    setState(() {
      _remainingSeconds = _focusMinutes * 60;
      _isRunning = false;
      _isPaused = false;
      _isScreenLocked = false; // Unlock when reset
    });
    
    if (_activeSessionId != null) {
      FocusService().endSession(_activeSessionId!);
      _activeSessionId = null;
    }
  }

  void _handlePhaseComplete() {
    _timer?.cancel();
    _rotationController.reset();
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isScreenLocked = false; // Unlock when phase completes
    });
    
    // Update completion count
    setState(() {
      _completedPomodoros++;
    });
    
    if (_activeSessionId != null) {
      FocusService().completePomodoro(_activeSessionId!, _completedPomodoros);
      FocusService().endSession(_activeSessionId!);
      _activeSessionId = null;
    }
    
    // Play alarm sound and show completion dialog
    _playAlarmSound();
  }

  void _playAlarmSound() {
    // Trigger system notification sound and vibration
    _triggerSystemAlarm();
    
    // Show completion dialog with option to start another session
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Session Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🎉 Great work!\n\nYou completed your focus session.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Would you like to start another session?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Just dismiss, timer is already reset
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset timer to focus time and allow user to start when ready
              setState(() {
                _remainingSeconds = _focusMinutes * 60;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start New Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerSystemAlarm() async {
    try {
      // Vibrate the device
      if (await Vibration.hasVibrator()) {
        // Pattern: vibrate for 500ms, pause 200ms, repeat 3 times
        Vibration.vibrate(
          pattern: [0, 500, 200, 500, 200, 500],
          intensities: [0, 255, 0, 255, 0, 255],
        );
      }

      // Play system notification sound
      await SystemSound.play(SystemSoundType.alert);
      
      // Wait a bit and play again for emphasis
      await Future.delayed(const Duration(milliseconds: 800));
      await SystemSound.play(SystemSoundType.alert);
      
      // Show visual feedback with snackbars
      for (int i = 0; i < 2; i++) {
        await Future.delayed(Duration(milliseconds: i * 400));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.celebration, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    '🎉 Session Complete!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 600),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      // Fallback: just show visual feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  '✅ Focus Session Completed!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }



  Future<void> _createNewSession() async {
    final sessionId = await FocusService().createFocusSession(
      taskId: _selectedTask?.id,
      taskTitle: _selectedTask?.title,
      duration: _focusMinutes,
      focusTime: _focusMinutes,
      breakTime: 5,
      longBreakTime: 15,
      sessionsBeforeLongBreak: 4,
    );
    
    setState(() {
      _activeSessionId = sessionId;
    });
  }

  void _showTaskSelector() async {
    final tasks = await TaskService().getUserTasks().first;
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No pending tasks'),
              )
            else
              ...tasks.map((task) => ListTile(
                leading: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                title: Text(task.title),
                subtitle: Text(task.category ?? 'No category'),
                onTap: () {
                  setState(() {
                    _selectedTask = task;
                  });
                  Navigator.pop(context);
                },
              )),
          ],
        ),
      ),
    );
  }

  void _showCustomTimeDialog() {
    _customTimeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Focus Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _customTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutes',
                hintText: 'Enter minutes (1-180)',
                prefixIcon: Icon(Icons.timer),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter any time from 1 to 180 minutes',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(_customTimeController.text);
              if (minutes != null && minutes > 0 && minutes <= 180) {
                setState(() {
                  _focusMinutes = minutes;
                  _remainingSeconds = minutes * 60;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid time (1-180 minutes)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
            ),
            child: const Text('Set Time'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SettingsModal(
        initialFocusMinutes: _focusMinutes,
        onSave: (newFocusMinutes) {
          setState(() {
            _focusMinutes = newFocusMinutes;
            if (!_isRunning && !_isPaused) {
              _remainingSeconds = _focusMinutes * 60;
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }



  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3: // High
        return Colors.red;
      case 2: // Medium
        return Colors.orange;
      case 1: // Low
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getPhaseColor() {
    return const Color(0xFF667EEA);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remainingSeconds / (_focusMinutes * 60));
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _isScreenLocked ? Colors.black87 : Colors.grey.shade50,
        appBar: _isScreenLocked
            ? null
            : AppBar(
                title: const Text('Focus Mode'),
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black87,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.timer_outlined),
                    onPressed: _showCustomTimeDialog,
                    tooltip: 'Custom Time',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: _showSettings,
                    tooltip: 'Settings',
                  ),
                ],
              ),
      body: _isScreenLocked 
          ? _buildLockedScreen()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Selected Task Card
            if (_selectedTask != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
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
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(_selectedTask!.priority),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTask!.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _selectedTask!.category ?? 'No category',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _selectedTask = null),
                    ),
                  ],
                ),
              ),

            // Timer Circle
            GestureDetector(
              onTap: _showTaskSelector,
              child: Container(
                width: double.infinity,
                height: 350,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getPhaseColor().withOpacity(0.1),
                      _getPhaseColor().withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating background circle
                      if (_isRunning)
                        RotationTransition(
                          turns: _rotationController,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _getPhaseColor().withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      
                      // Progress Circle
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CustomPaint(
                          painter: CircularProgressPainter(
                            progress: progress,
                            color: _getPhaseColor(),
                          ),
                        ),
                      ),
                      
                      // Timer Content
                      ScaleTransition(
                        scale: _isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Focus Session',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _getPhaseColor(),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _formatTime(_remainingSeconds),
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_completedPomodoros > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle, 
                                      color: Colors.green, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$_completedPomodoros completed today',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isRunning || _isPaused)
                  FloatingActionButton(
                    heroTag: 'reset',
                    onPressed: _resetTimer,
                    backgroundColor: Colors.red.shade400,
                    child: const Icon(Icons.stop),
                  ),
                const SizedBox(width: 20),
                FloatingActionButton.extended(
                  heroTag: 'play_pause',
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  backgroundColor: _getPhaseColor(),
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : (_isPaused ? 'Resume' : 'Start')),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Screen Lock Warning
            if (!_isRunning && !_isPaused)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Phone will lock when timer starts',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.playlist_add_check,
                    label: 'Select Task',
                    onTap: _showTaskSelector,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.bar_chart,
                    label: 'Statistics',
                    onTap: () => _showStats(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Session Stats
            Container(
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, 
                        color: Colors.amber.shade600, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Today\'s Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.check_circle,
                        value: _completedPomodoros.toString(),
                        label: 'Sessions',
                        color: Colors.green,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      _buildStatItem(
                        icon: Icons.timer_outlined,
                        value: '${(_completedPomodoros * _focusMinutes)}',
                        label: 'Minutes',
                        color: const Color(0xFF667EEA),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildLockedScreen() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 80,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            const Text(
              'Focus Mode Active',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Focus Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _getPhaseColor(),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            ScaleTransition(
              scale: _pulseAnimation,
              child: Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_selectedTask != null) ...[
              const Text(
                'Working on:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30),
                ),
                child: Text(
                  _selectedTask!.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
            ],
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white30),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.phone_disabled,
                    color: Colors.white70,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Phone Locked During Focus',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stay focused! Press back button\nto exit and unlock your phone',
                    textAlign: TextAlign.center,
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
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF667EEA)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showStats() async {
    final stats = await FocusService().getStats();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Today\'s Focus Stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Pomodoros', stats['todayPomodoros'].toString()),
            _buildStatRow('Minutes', stats['todayMinutes'].toString()),
            _buildStatRow('Sessions', stats['todaySessions'].toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsModal extends StatefulWidget {
  final int initialFocusMinutes;
  final Function(int) onSave;

  const _SettingsModal({
    required this.initialFocusMinutes,
    required this.onSave,
  });

  @override
  State<_SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<_SettingsModal> {
  late int _focusMinutes;

  @override
  void initState() {
    super.initState();
    // Clamp the initial value to valid range
    _focusMinutes = widget.initialFocusMinutes.clamp(5, 120);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, color: Color(0xFF667EEA)),
                SizedBox(width: 12),
                Text(
                  'Focus Session Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Customize your focus session duration',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            _buildSettingSlider(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Tip',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the timer icon (⏱️) in the top bar for custom one-time durations.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onSave(_focusMinutes),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Default Focus Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF667EEA),
                      Color(0xFF667EEA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_focusMinutes min',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: const Color(0xFF667EEA),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: const Color(0xFF667EEA),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              overlayColor: const Color(0xFF667EEA).withOpacity(0.2),
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: Slider(
              value: _focusMinutes.toDouble().clamp(5.0, 120.0),
              min: 5.0,
              max: 120.0,
              divisions: 23,
              onChanged: (value) {
                setState(() {
                  _focusMinutes = value.toInt().clamp(5, 120);
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 min',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '120 min',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

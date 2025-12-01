import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/task_service.dart';
import '../services/activity_service.dart';
import '../services/focus_service.dart';
import '../models/task_model.dart';
import '../models/focus_session_model.dart';
import 'task_detail_sheet.dart';
import 'stats_screen.dart';
import '../widgets/celebration_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getUserName() {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user!.displayName!.split(' ').first;
    }
    if (user?.email != null) {
      return user!.email!.split('@')[0];
    }
    return 'Student';
  }

  String _getUserInitials() {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      final parts = user!.displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    if (user?.email != null) {
      return user!.email![0].toUpperCase();
    }
    return 'S';
  }

  String _getUserEmail() {
    return user?.email ?? 'No email';
  }

  String _getUserFullName() {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user!.displayName!;
    }
    if (user?.email != null) {
      return user!.email!.split('@')[0];
    }
    return 'Student';
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getUserInitials(),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getUserFullName(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.email_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _getUserEmail(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Profile Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to edit profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit Profile - Coming Soon!')),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/notification-settings');
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.dark_mode_outlined,
                    title: 'Appearance',
                    subtitle: 'Theme and display settings',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to appearance settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appearance - Coming Soon!')),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.security_outlined,
                    title: 'Privacy & Security',
                    subtitle: 'Manage your account security',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to privacy settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy - Coming Soon!')),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to help
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help - Coming Soon!')),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Show about dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('StudyBuddy v1.0.0')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your account',
                    isDestructive: true,
                    onTap: () async {
                      // Close the profile modal first
                      Navigator.pop(context);
                      
                      // Show confirmation dialog
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Sign Out'),
                            ],
                          ),
                          content: const Text(
                            'Are you sure you want to sign out?',
                            style: TextStyle(fontSize: 16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        // Sign out from Firebase
                        await FirebaseAuth.instance.signOut();
                        
                        // Navigate to landing page and clear all routes
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                            '/landing',
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.shade50
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? Colors.red.shade100
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.shade100
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFF667EEA),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDestructive ? Colors.red.shade700 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDestructive
                          ? Colors.red.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDestructive ? Colors.red.shade300 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: _selectedIndex == 0 ? _buildHomeTab() : _buildOtherTab(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        // Custom App Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getUserName(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showProfileModal(),
                      child: Hero(
                        tag: 'profile_avatar',
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getUserInitials(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Today's Progress Summary Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                StreamBuilder<List<Task>>(
                  stream: TaskService().getUserTasks(),
                  builder: (context, taskSnapshot) {
                    return StreamBuilder<List<FocusSession>>(
                      stream: FocusService().getTodaySessions(),
                      builder: (context, focusSnapshot) {
                        return StreamBuilder<int>(
                          stream: TaskService().getTaskStreakStream(),
                          builder: (context, streakSnapshot) {
                            final tasks = taskSnapshot.data ?? [];
                            final sessions = focusSnapshot.data ?? [];
                            final streak = streakSnapshot.data ?? 0;
                            
                            final now = DateTime.now();
                            final todayTasks = tasks.where((t) {
                              return t.createdAt.year == now.year &&
                                  t.createdAt.month == now.month &&
                                  t.createdAt.day == now.day;
                            }).toList();
                            final completedToday = todayTasks.where((t) => t.isCompleted).length;
                            final totalToday = todayTasks.length;
                            
                            int totalMinutes = 0;
                            for (var s in sessions) {
                              if (s.isCompleted && s.endTime != null) {
                                totalMinutes += s.endTime!.difference(s.startTime).inMinutes;
                              } else if (!s.isCompleted) {
                                final elapsed = now.difference(s.startTime).inMinutes;
                                totalMinutes += elapsed.clamp(0, s.duration);
                              }
                            }
                            
                            final hours = totalMinutes >= 60 
                                ? '${(totalMinutes / 60).toStringAsFixed(1)}h'
                                : '${totalMinutes}m';
                            
                            // Calculate productivity percentage
                            final productivityScore = totalToday > 0 
                                ? (completedToday / totalToday * 100).round()
                                : 0;
                            
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667EEA).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Today\'s Progress',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Keep pushing forward!',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (productivityScore > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.emoji_events,
                                                color: Colors.amber,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '$productivityScore%',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildProgressMetric(
                                          icon: Icons.timer_outlined,
                                          label: 'Focus Time',
                                          value: hours,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 50,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      Expanded(
                                        child: _buildProgressMetric(
                                          icon: Icons.check_circle_outline,
                                          label: 'Tasks Done',
                                          value: '$completedToday/$totalToday',
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 50,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      Expanded(
                                        child: _buildProgressMetric(
                                          icon: Icons.local_fire_department,
                                          label: 'Streak',
                                          value: '${streak}d',
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      'Focus Mode',
                      Icons.psychology_outlined,
                      const Color(0xFF667EEA),
                      () {
                        Navigator.pushNamed(context, '/focus');
                      },
                    ),
                    _buildQuickAction(
                      'Add Task',
                      Icons.add_task,
                      const Color(0xFF764BA2),
                      () {
                        Navigator.pushNamed(context, '/add-task');
                      },
                    ),
                    _buildQuickAction(
                      'YouTube',
                      Icons.play_circle_outline,
                      const Color(0xFFFF4081),
                      () {
                        Navigator.pushNamed(context, '/youtube');
                      },
                    ),
                    _buildQuickAction(
                      'Routine',
                      Icons.calendar_today,
                      const Color(0xFF00BCD4),
                      () {
                        Navigator.pushNamed(context, '/routine');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Extra-Curricular Activities & Prayer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance Your Life 🌟',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Prayer Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF56CCF2).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.mosque,
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
                              'Prayer Time ☪️',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Take a break for spiritual growth',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, '/balance-your-life');
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Extra-Curricular Activities Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Extra-Curricular Activities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/extra-curricular');
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Today's Activities Summary - Using StreamBuilder for real-time updates
                StreamBuilder<Map<String, dynamic>>(
                  stream: ActivityService().getTodaySummary(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      // Show placeholder on error
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/extra-curricular');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667EEA).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF667EEA).withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.sports_handball,
                                size: 48,
                                color: const Color(0xFF667EEA).withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to log activities',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final stats = snapshot.data ?? {};
                    final todayMinutes = stats['todayMinutes'] ?? 0;
                    final todayCount = stats['todayCount'] ?? 0;
                    final categoryStats = stats['categoryStats'] as Map<String, int>? ?? {};

                    if (todayCount == 0) {
                      // Show placeholder when no activities today
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/extra-curricular');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667EEA).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF667EEA).withOpacity(0.2),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.sports_handball,
                                size: 48,
                                color: const Color(0xFF667EEA).withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No activities logged today',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to start tracking your activities!',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Show today's summary
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
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
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Today\'s Activities',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$todayCount ${todayCount == 1 ? 'activity' : 'activities'} • $todayMinutes minutes',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/extra-curricular');
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Show top categories if available
                        if (categoryStats.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categoryStats.entries.take(4).map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _getCategoryColorByName(entry.key).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getCategoryColorByName(entry.key).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIconByName(entry.key),
                                      size: 16,
                                      color: _getCategoryColorByName(entry.key),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${entry.key}: ${entry.value}m',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getCategoryColorByName(entry.key),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Today's Tasks
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to all tasks
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<Task>>(
                  stream: TaskService().getUserTasks(),
                  builder: (context, snapshot) {
                    print('🔷 Tasks StreamBuilder - Connection: ${snapshot.connectionState}');
                    print('🔷 Tasks StreamBuilder - Has Error: ${snapshot.hasError}');
                    if (snapshot.hasError) {
                      print('🔷 Tasks StreamBuilder - Error: ${snapshot.error}');
                    }
                    
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      final errorMessage = snapshot.error.toString();
                      final isPermissionError = errorMessage.contains('permission-denied') || 
                                                errorMessage.contains('PERMISSION_DENIED');
                      final isIndexError = errorMessage.contains('failed-precondition');
                      
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isPermissionError ? Colors.orange.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPermissionError ? Colors.orange.shade200 : Colors.red.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isPermissionError ? Icons.lock_outline : Icons.error_outline,
                              size: 48,
                              color: isPermissionError ? Colors.orange.shade400 : Colors.red.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isPermissionError ? 'Please Sign In' : 'Error Loading Tasks',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isPermissionError ? Colors.orange.shade700 : Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isPermissionError
                                  ? 'You need to sign in to view your tasks.'
                                  : isIndexError
                                      ? 'Database index is building...\nPlease wait a few minutes.'
                                      : 'Unable to load tasks.\nPlease check your connection.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isPermissionError ? Colors.orange.shade600 : Colors.red.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (isPermissionError) {
                                  // Navigate to landing and clear stack
                                  // Use root navigator to avoid issues if this widget rebuilds during auth state change
                                  final rootContext = Navigator.of(context, rootNavigator: true).context;
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    Navigator.of(rootContext).pushNamedAndRemoveUntil(
                                      '/landing',
                                      (route) => false,
                                    );
                                  });
                                } else {
                                  // Trigger rebuild
                                  setState(() {});
                                }
                              },
                              icon: Icon(isPermissionError ? Icons.login : Icons.refresh),
                              label: Text(isPermissionError ? 'Sign In' : 'Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPermissionError ? Colors.orange.shade400 : Colors.red.shade400,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final tasks = snapshot.data ?? [];
                    print('🔷 Tasks StreamBuilder - Tasks count: ${tasks.length}');

                    // Separate active and completed tasks
                    final now = DateTime.now();
                    
                    final activeTasks = tasks.where((task) => !task.isCompleted).toList();
                    final completedToday = tasks.where((task) {
                      if (!task.isCompleted) return false;
                      // If completedAt is null (old tasks), show them anyway
                      if (task.completedAt == null) return true;
                      // Check if completed within last 24 hours
                      final timeDiff = now.difference(task.completedAt!);
                      return timeDiff.inHours < 24;
                    }).toList();

                    if (tasks.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks yet!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "Add Task" to create your first task',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Sort active tasks by startAt (earliest first), fallback to dueDate
                    activeTasks.sort((a, b) {
                      final aTime = a.startAt ?? a.dueDate;
                      final bTime = b.startAt ?? b.dueDate;
                      if (aTime == null && bTime == null) return 0;
                      if (aTime == null) return 1;
                      if (bTime == null) return -1;
                      return aTime.compareTo(bTime);
                    });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Active Tasks
                        if (activeTasks.isNotEmpty) ...[
                          ...activeTasks.asMap().entries.map((entry) {
                            final task = entry.value;
                            final index = entry.key;
                            
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < activeTasks.length - 1 ? 12.0 : 0,
                              ),
                              child: _buildTaskCard(
                                task,
                                _getColorForPriority(task.priority),
                              ),
                            );
                          }),
                        ],
                        
                        // Completed Today Section
                        if (completedToday.isNotEmpty) ...[
                          if (activeTasks.isNotEmpty) const SizedBox(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Completed Today',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${completedToday.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...completedToday.asMap().entries.map((entry) {
                            final task = entry.value;
                            final index = entry.key;
                            
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < completedToday.length - 1 ? 12.0 : 0,
                              ),
                              child: _buildTaskCard(
                                task,
                                Colors.green,
                              ),
                            );
                          }),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Study Streak with Real Data
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder<int>(
              stream: TaskService().getTaskStreakStream(),
              builder: (context, streakSnapshot) {
                return StreamBuilder<List<Task>>(
                  stream: TaskService().getUserTasks(),
                  builder: (context, tasksSnapshot) {
                    final streak = streakSnapshot.data ?? 0;
                    final tasks = tasksSnapshot.data ?? [];
                    
                    // Get completed task dates for last 7 days
                    final now = DateTime.now();
                    final last7Days = List.generate(7, (index) {
                      final date = now.subtract(Duration(days: 6 - index));
                      return DateTime(date.year, date.month, date.day);
                    });
                    
                    final completedDates = tasks
                        .where((t) => t.isCompleted && t.completedAt != null)
                        .map((t) {
                          final date = t.completedAt!;
                          return DateTime(date.year, date.month, date.day);
                        })
                        .toSet();
                    
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: streak > 0 
                              ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                              : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (streak > 0 ? const Color(0xFFFF6B6B) : const Color(0xFF667EEA))
                                .withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  streak > 0 
                                      ? Icons.local_fire_department
                                      : Icons.whatshot_outlined,
                                  color: streak > 0 ? Colors.orange : Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      streak > 0 
                                          ? '$streak Day Streak! 🔥'
                                          : 'Start Your Streak!',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      streak > 0
                                          ? 'Amazing consistency!'
                                          : 'Complete tasks to build momentum',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (streak >= 7)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.emoji_events,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(
                              7,
                              (index) {
                                final date = last7Days[index];
                                final hasActivity = completedDates.contains(date);
                                final isToday = date.year == now.year &&
                                    date.month == now.month &&
                                    date.day == now.day;
                                
                                return Column(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: hasActivity
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: isToday
                                            ? Border.all(
                                                color: Colors.amber,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: hasActivity
                                          ? Icon(
                                              Icons.check,
                                              color: streak > 0
                                                  ? const Color(0xFFFF6B6B)
                                                  : const Color(0xFF667EEA),
                                              size: 20,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                                          [(date.weekday - 1) % 7],
                                      style: TextStyle(
                                        color: hasActivity
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                        fontWeight: hasActivity
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }


  Widget _buildProgressMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColorByName(String category) {
    final colorMap = {
      'Sports': const Color(0xFF4CAF50),
      'Music': const Color(0xFFFF9800),
      'Art': const Color(0xFFE91E63),
      'Reading': const Color(0xFF9C27B0),
      'Dance': const Color(0xFFFF5722),
      'Photography': const Color(0xFF00BCD4),
      'Coding': const Color(0xFF3F51B5),
      'Volunteering': const Color(0xFFFFC107),
    };
    return colorMap[category] ?? const Color(0xFF667EEA);
  }

  IconData _getCategoryIconByName(String category) {
    final iconMap = {
      'Sports': Icons.sports_soccer,
      'Music': Icons.music_note,
      'Art': Icons.palette,
      'Reading': Icons.menu_book,
      'Dance': Icons.celebration,
      'Photography': Icons.camera_alt,
      'Coding': Icons.code,
      'Volunteering': Icons.volunteer_activism,
    };
    return iconMap[category] ?? Icons.star;
  }

  Widget _buildTaskCard(Task task, Color color) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TaskDetailSheet(task: task),
        );
      },
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: task.isCompleted 
                ? Colors.green.shade50
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: task.isCompleted
                ? Border.all(color: Colors.green.shade300, width: 2)
                : null,
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
              if (task.isCompleted)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                )
              else
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: task.isCompleted
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              if (task.isCompleted)
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      height: 2,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (task.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.category!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: color,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      children: [
                        Text(
                          _formatSchedule(task),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (task.isCompleted)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 1.5,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            Checkbox(
              value: task.isCompleted,
              onChanged: task.isCompleted
                  ? null // Disable checkbox if already completed
                  : (value) async {
                      try {
                        await TaskService().toggleTaskCompletion(task.id, task.isCompleted);
                        
                        // Show feedback when checkbox is toggled
                        if (mounted) {
                          if (value == true) {
                            // Show celebration overlay
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: Colors.transparent,
                              builder: (context) => const CelebrationOverlay(),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating task: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              shape: const CircleBorder(),
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForPriority(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF00BCD4); // Low - Cyan
      case 2:
        return const Color(0xFF667EEA); // Medium - Purple
      case 3:
        return const Color(0xFFFF4081); // High - Pink
      default:
        return const Color(0xFF667EEA);
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (taskDate == today) {
      return 'Due: ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Due: Tomorrow';
    } else {
      return 'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }
  
  String _formatSchedule(Task task) {
    // If start/end present, format window; else fallback to due date
    if (task.startAt != null && task.endAt != null) {
      final start = task.startAt!;
      final end = task.endAt!;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(start.year, start.month, start.day);
      final startStr = _formatTimeWithAmPm(start);
      final endStr = _formatTimeWithAmPm(end);
      if (dateOnly == today) {
        return 'Today: $startStr - $endStr';
      }
      return '${start.day}/${start.month}/${start.year}: $startStr - $endStr';
    }
    if (task.dueDate != null) {
      return _formatDueDate(task.dueDate!);
    }
    return 'No schedule';
  }

  String _formatTimeWithAmPm(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    if (hour == 0) {
      return '12:$minute AM';
    } else if (hour < 12) {
      return '$hour:$minute AM';
    } else if (hour == 12) {
      return '12:$minute PM';
    } else {
      return '${hour - 12}:$minute PM';
    }
  }

  Widget _buildOtherTab() {
    return const StatsScreen();
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.calendar_today_rounded, 'Routine', 1),
              _buildNavItem(Icons.psychology_rounded, 'Focus', 2),
              _buildNavItem(Icons.bar_chart_rounded, 'Stats', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return GestureDetector(
      onTap: () async {
        // Navigate to different screens based on index
        if (index == 1) {
          await Navigator.pushNamed(context, '/routine');
          // Reset to home tab when returning
          setState(() {
            _selectedIndex = 0;
          });
        } else if (index == 2) {
          await Navigator.pushNamed(context, '/focus');
          // Reset to home tab when returning
          setState(() {
            _selectedIndex = 0;
          });
        } else {
          // For Home and Stats, just change tab
          setState(() {
            _selectedIndex = index;
          });
        }
        // Add navigation for Stats (index 3) as feature is implemented
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

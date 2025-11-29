import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';
import '../services/routine_service.dart';
import '../services/focus_service.dart';
import '../models/task_model.dart';
import '../models/focus_session_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  final RoutineService _routineService = RoutineService();
  final FocusService _focusService = FocusService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Statistics',
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Focus'),
                      Tab(text: 'Tasks'),
                      Tab(text: 'Productivity'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildFocusTab(),
            _buildTasksTab(),
            _buildProductivityTab(),
          ],
        ),
      ),
    );
  }

  // Overview Tab
  Widget _buildOverviewTab() {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
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
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your productivity',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Overview Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                  children: [
                    _buildStatsOverviewCard(
                      'Total Tasks',
                      Icons.task_alt_rounded,
                      const Color(0xFF667EEA),
                      FutureBuilder<int>(
                        future: _taskService.getTaskCount(),
                        builder: (context, snapshot) {
                          return Text(
                            '${snapshot.data ?? 0}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF667EEA),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildStatsOverviewCard(
                      'Completed',
                      Icons.check_circle_rounded,
                      const Color(0xFF10B981),
                      FutureBuilder<int>(
                        future: _taskService.getTaskCount(isCompleted: true),
                        builder: (context, snapshot) {
                          return Text(
                            '${snapshot.data ?? 0}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildStatsOverviewCard(
                      'Active Routines',
                      Icons.schedule_rounded,
                      const Color(0xFFF59E0B),
                      FutureBuilder<int>(
                        future: _routineService.getRoutineCount(),
                        builder: (context, snapshot) {
                          return Text(
                            '${snapshot.data ?? 0}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59E0B),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildStatsOverviewCard(
                      'Focus Time',
                      Icons.timer_rounded,
                      const Color(0xFFEC4899),
                      StreamBuilder<List<FocusSession>>(
                        stream: _focusService.getTodaySessions(),
                        builder: (context, snapshot) {
                          print('📊 Focus Time Card - Connection: ${snapshot.connectionState}');
                          print('📊 Focus Time Card - Has Data: ${snapshot.hasData}');
                          print('📊 Focus Time Card - Data: ${snapshot.data}');
                          
                          if (!snapshot.hasData) {
                            return const Text(
                              '0.0h',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEC4899),
                              ),
                            );
                          }
                          
                          final sessions = snapshot.data!;
                          print('📊 Focus Time Card - Sessions count: ${sessions.length}');
                          
                          int totalMinutes = 0;
                          final now = DateTime.now();
                          
                          for (var session in sessions) {
                            print('📊 Session: ${session.taskTitle ?? "No task"}, duration: ${session.duration}, completed: ${session.isCompleted}');
                            if (session.isCompleted && session.endTime != null) {
                              final mins = session.endTime!.difference(session.startTime).inMinutes;
                              print('📊 Completed session - adding $mins minutes');
                              totalMinutes += mins;
                            } else {
                              final elapsed = now.difference(session.startTime).inMinutes;
                              final clamped = elapsed.clamp(0, session.duration).toInt();
                              print('📊 Active session - adding $clamped minutes (elapsed: $elapsed)');
                              totalMinutes += clamped;
                            }
                          }
                          
                          print('📊 Total minutes: $totalMinutes');
                          final hours = totalMinutes > 0 ? (totalMinutes / 60).toStringAsFixed(1) : '0.0';
                          print('📊 Display hours: ${hours}h');
                          
                          return Text(
                            '${hours}h',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEC4899),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Today's Performance
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Performance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<int>(
                  stream: _taskService.getCompletedTasksTodayStream(),
                  builder: (context, snapshot) {
                    final completedToday = snapshot.data ?? 0;
                    
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF10B981).withOpacity(0.1),
                            const Color(0xFF10B981).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tasks Completed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$completedToday',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  size: 48,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  completedToday >= 5
                                      ? 'Great progress!'
                                      : completedToday >= 3
                                          ? 'Keep it up!'
                                          : 'You can do it!',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Focus Sessions Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Focus Sessions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<FocusSession>>(
                  stream: _focusService.getTodaySessions(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFEC4899).withOpacity(0.1),
                              const Color(0xFFEC4899).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFEC4899).withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_off_rounded,
                                size: 48,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No Focus Sessions Today',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Start a focus session to track your time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    final sessions = snapshot.data!;
                    int todayMinutes = 0;
                    int todayCount = sessions.length;
                    final categoryStats = <String, int>{};
                    
                    final now = DateTime.now();
                    for (var session in sessions) {
                      // Calculate minutes
                      if (session.isCompleted && session.endTime != null) {
                        todayMinutes += session.endTime!.difference(session.startTime).inMinutes;
                      } else {
                        final elapsed = now.difference(session.startTime).inMinutes;
                        todayMinutes += elapsed.clamp(0, session.duration).toInt();
                      }
                      
                      // Category stats
                      if (session.taskTitle != null) {
                        final category = session.taskTitle!;
                        categoryStats[category] = (categoryStats[category] ?? 0) + 
                          (session.isCompleted && session.endTime != null
                            ? session.endTime!.difference(session.startTime).inMinutes
                            : now.difference(session.startTime).inMinutes.clamp(0, session.duration).toInt());
                      }
                    }
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFEC4899).withOpacity(0.1),
                            const Color(0xFFEC4899).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFEC4899).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: _buildFocusStatItem(
                                  Icons.timer_rounded,
                                  '${(todayMinutes / 60).toStringAsFixed(1)}h',
                                  'Focus Time',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: const Color(0xFFEC4899).withOpacity(0.3),
                              ),
                              Expanded(
                                child: _buildFocusStatItem(
                                  Icons.autorenew_rounded,
                                  '$todayCount',
                                  'Sessions',
                                ),
                              ),
                            ],
                          ),
                          if (categoryStats.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text(
                              'Time by Category',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...categoryStats.entries.map((entry) {
                              final percentage = todayMinutes > 0
                                  ? (entry.value / todayMinutes * 100).toInt()
                                  : 0;
                              return _buildCategoryProgressBar(
                                entry.key,
                                entry.value,
                                percentage,
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Task Categories
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Task>>(
                  stream: _taskService.getUserTasks(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    
                    final tasks = snapshot.data!;
                    final categoryCount = <String, int>{};
                    
                    for (final task in tasks) {
                      final category = task.category ?? 'Other';
                      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
                    }
                    
                    if (categoryCount.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: categoryCount.entries.map((entry) {
                        return _buildCategoryChip(entry.key, entry.value);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Weekly Trend
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Trend',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Task>>(
                  stream: _taskService.getUserTasks(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final tasks = snapshot.data!;
                    final now = DateTime.now();
                    final weekData = <String, Map<String, int>>{};
                    
                    // Generate last 7 days
                    for (int i = 6; i >= 0; i--) {
                      final date = now.subtract(Duration(days: i));
                      final dayKey = _getDayKey(date);
                      weekData[dayKey] = {'total': 0, 'completed': 0};
                    }
                    
                    // Count tasks for each day
                    for (var task in tasks) {
                      final taskDate = task.createdAt;
                      final dayKey = _getDayKey(taskDate);
                      
                      if (weekData.containsKey(dayKey)) {
                        weekData[dayKey]!['total'] = (weekData[dayKey]!['total'] ?? 0) + 1;
                        if (task.isCompleted) {
                          weekData[dayKey]!['completed'] = (weekData[dayKey]!['completed'] ?? 0) + 1;
                        }
                      }
                    }
                    
                    final maxTasks = weekData.values
                        .map((day) => day['total'] ?? 0)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble();
                    final chartHeight = maxTasks > 0 ? 150.0 : 100.0;
                    
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF667EEA).withOpacity(0.1),
                            const Color(0xFF667EEA).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Last 7 Days',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667EEA).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.insights_rounded,
                                      size: 14,
                                      color: const Color(0xFF667EEA),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Tasks',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF667EEA),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: chartHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: weekData.entries.map((entry) {
                                final total = entry.value['total'] ?? 0;
                                final completed = entry.value['completed'] ?? 0;
                                final dayLabel = entry.key;
                                final barHeight = maxTasks > 0
                                    ? (total / maxTasks) * (chartHeight - 30)
                                    : 20.0;
                                final completedHeight = total > 0
                                    ? (completed / total) * barHeight
                                    : 0.0;
                                
                                return _buildWeeklyBar(
                                  dayLabel,
                                  barHeight,
                                  completedHeight,
                                  total,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Focus Tab
  Widget _buildFocusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFocusSummary(),
          const SizedBox(height: 24),
          _buildRecentSessions(),
        ],
      ),
    );
  }

  Widget _buildFocusSummary() {
    return StreamBuilder<List<FocusSession>>(
      stream: _focusService.getTodaySessions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = snapshot.data!;
        int totalMinutes = 0;
        int completedSessions = 0;

        for (var session in sessions) {
          if (session.endTime != null) {
            totalMinutes += session.endTime!.difference(session.startTime).inMinutes;
            if (session.isCompleted) completedSessions++;
          }
        }

        final hours = (totalMinutes / 60).toStringAsFixed(1);
        final avgMinutes = sessions.isNotEmpty ? (totalMinutes / sessions.length).toInt() : 0;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
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
                    child: const Icon(Icons.psychology, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Focus Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Today\'s focus activity',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
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
                    child: _buildFocusMetric('Total Time', '${hours}h', Icons.timer),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFocusMetric('Sessions', '${sessions.length}', Icons.list_alt),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFocusMetric('Avg/Session', '${avgMinutes}m', Icons.speed),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFocusMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions() {
    return StreamBuilder<List<FocusSession>>(
      stream: _focusService.getTodaySessions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = snapshot.data!;

        if (sessions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.self_improvement, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No focus sessions yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a focus session to see your progress',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
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
                    Icon(Icons.history, color: Theme.of(context).primaryColor, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Recent Sessions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length > 5 ? 5 : sessions.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final duration = session.endTime != null
                      ? session.endTime!.difference(session.startTime).inMinutes
                      : session.duration;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: session.isCompleted
                              ? [const Color(0xFF10B981), const Color(0xFF059669)]
                              : [Colors.orange, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        session.isCompleted ? Icons.check_circle : Icons.timer,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      session.taskTitle ?? 'Focus Session',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('hh:mm a').format(session.startTime),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${duration}m',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Tasks Tab  
  Widget _buildTasksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskCategories(),
          const SizedBox(height: 24),
          _buildTaskTrends(),
        ],
      ),
    );
  }

  Widget _buildTaskCategories() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getUserTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!;
        final categoryMap = <String, int>{};

        for (var task in tasks) {
          final category = task.category ?? 'Uncategorized';
          categoryMap[category] = (categoryMap[category] ?? 0) + 1;
        }

        final categories = categoryMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
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
                  Icon(Icons.category, color: Theme.of(context).primaryColor, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Task Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (categories.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No tasks yet',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              else
                ...categories.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(entry.key).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getCategoryIcon(entry.key),
                              color: _getCategoryColor(entry.key),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: entry.value / tasks.length,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getCategoryColor(entry.key),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${entry.value}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskTrends() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getUserTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final tasks = snapshot.data!;
        final total = tasks.length;
        final completed = tasks.where((t) => t.isCompleted).length;
        final pending = total - completed;
        final completionRate = total > 0 ? ((completed / total) * 100).toInt() : 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF59E0B).withOpacity(0.1),
                const Color(0xFFF59E0B).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF59E0B).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up, color: Color(0xFFF59E0B), size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Task Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricBox('Total', '$total', Icons.task, Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricBox('Completed', '$completed', Icons.check_circle, const Color(0xFF10B981)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricBox('Pending', '$pending', Icons.pending, Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.speed, color: Theme.of(context).primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Completion Rate',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '$completionRate%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Productivity Tab - NEW FEATURE!
  Widget _buildProductivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductivityScore(),
          const SizedBox(height: 24),
          _buildProductivityBreakdown(),
          const SizedBox(height: 24),
          _buildWeeklyProductivityTrend(),
        ],
      ),
    );
  }

  Widget _buildProductivityScore() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getUserTasks(),
      builder: (context, taskSnapshot) {
        return StreamBuilder<List<FocusSession>>(
          stream: _focusService.getTodaySessions(),
          builder: (context, focusSnapshot) {
            return FutureBuilder<int>(
              future: _routineService.getRoutineCount(),
              builder: (context, routineSnapshot) {
                if (!taskSnapshot.hasData || !focusSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Calculate Productivity Score (0-100)
                final tasks = taskSnapshot.data!;
                final focusSessions = focusSnapshot.data!;
                final todayTasks = tasks.where((t) {
                  final today = DateTime.now();
                  return t.createdAt.year == today.year &&
                      t.createdAt.month == today.month &&
                      t.createdAt.day == today.day;
                }).toList();

                final completedTasks = todayTasks.where((t) => t.isCompleted).length;
                final totalTasks = todayTasks.length;
                final completedSessions = focusSessions.where((s) => s.isCompleted).length;
                
                int totalMinutes = 0;
                for (var session in focusSessions) {
                  if (session.endTime != null) {
                    totalMinutes += session.endTime!.difference(session.startTime).inMinutes;
                  }
                }

                // Scoring Formula
                double taskScore = totalTasks > 0 ? (completedTasks / totalTasks * 40) : 0;
                double focusScore = (completedSessions * 5).clamp(0, 30).toDouble();
                double minutesScore = (totalMinutes / 120 * 30).clamp(0, 30);
                
                int productivityScore = (taskScore + focusScore + minutesScore).toInt();
                
                String level;
                Color levelColor;
                IconData levelIcon;
                
                if (productivityScore >= 80) {
                  level = 'Highly Productive';
                  levelColor = const Color(0xFF10B981);
                  levelIcon = Icons.emoji_events;
                } else if (productivityScore >= 60) {
                  level = 'Productive';
                  levelColor = const Color(0xFF3B82F6);
                  levelIcon = Icons.trending_up;
                } else if (productivityScore >= 40) {
                  level = 'Moderate';
                  levelColor = const Color(0xFFF59E0B);
                  levelIcon = Icons.remove_circle_outline;
                } else if (productivityScore >= 20) {
                  level = 'Low';
                  levelColor = const Color(0xFFEF4444);
                  levelIcon = Icons.trending_down;
                } else {
                  level = 'Needs Improvement';
                  levelColor = const Color(0xFF991B1B);
                  levelIcon = Icons.warning_amber;
                }

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [levelColor, levelColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(levelIcon, color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        '$productivityScore',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        level,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Productivity Score',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProductivityBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              Icon(Icons.analytics, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Score Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBreakdownItem('Task Completion', 40, Icons.task_alt, Colors.blue),
          const SizedBox(height: 12),
          _buildBreakdownItem('Focus Sessions', 30, Icons.timer, Colors.purple),
          const SizedBox(height: 12),
          _buildBreakdownItem('Study Minutes', 30, Icons.timelapse, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String title, int maxScore, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Max: $maxScore points',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProductivityTrend() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getUserTasks(),
      builder: (context, taskSnapshot) {
        return StreamBuilder<List<FocusSession>>(
          stream: _focusService.getTodaySessions(),
          builder: (context, focusSnapshot) {
            if (!taskSnapshot.hasData || !focusSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final tasks = taskSnapshot.data!;
            final focusSessions = focusSnapshot.data!;
            final todayTasks = tasks.where((t) {
              final today = DateTime.now();
              return t.createdAt.year == today.year &&
                  t.createdAt.month == today.month &&
                  t.createdAt.day == today.day;
            }).toList();

            final completedTasks = todayTasks.where((t) => t.isCompleted).length;
            final completedSessions = focusSessions.where((s) => s.isCompleted).length;
            
            int totalMinutes = 0;
            for (var session in focusSessions) {
              if (session.endTime != null) {
                totalMinutes += session.endTime!.difference(session.startTime).inMinutes;
              }
            }

            // Generate insights based on data
            List<Map<String, dynamic>> insights = [];

            if (completedTasks >= 5) {
              insights.add({
                'icon': Icons.emoji_events,
                'color': const Color(0xFF10B981),
                'title': 'Great Progress!',
                'message': 'You completed $completedTasks tasks today',
              });
            }

            if (totalMinutes >= 60) {
              insights.add({
                'icon': Icons.psychology,
                'color': const Color(0xFF8B5CF6),
                'title': 'Focus Champion',
                'message': '${(totalMinutes/60).toStringAsFixed(1)} hours of focused work',
              });
            }

            if (completedSessions >= 3) {
              insights.add({
                'icon': Icons.local_fire_department,
                'color': const Color(0xFFEF4444),
                'title': 'On Fire! 🔥',
                'message': '$completedSessions focus sessions completed',
              });
            }

            if (insights.isEmpty) {
              insights.add({
                'icon': Icons.tips_and_updates,
                'color': const Color(0xFFF59E0B),
                'title': 'Start Your Day Strong',
                'message': 'Complete tasks and focus sessions to boost your score',
              });
            }

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
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
                      Icon(Icons.insights, color: Theme.of(context).primaryColor, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Productivity Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...insights.map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: insight['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: insight['color'].withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: insight['color'].withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  insight['icon'],
                                  color: insight['color'],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      insight['title'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: insight['color'],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      insight['message'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.green;
      case 'study':
        return Colors.purple;
      case 'health':
        return Colors.red;
      case 'shopping':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'study':
        return Icons.school;
      case 'health':
        return Icons.favorite;
      case 'shopping':
        return Icons.shopping_cart;
      default:
        return Icons.label;
    }
  }

  Widget _buildStatsOverviewCard(
    String title,
    IconData icon,
    Color color,
    Widget valueWidget,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const Spacer(),
          valueWidget,
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusStatItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFFEC4899),
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEC4899),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryProgressBar(String category, int minutes, int percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${minutes}m ($percentage%)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, int count) {
    final colors = {
      'Work': const Color(0xFF667EEA),
      'Personal': const Color(0xFF10B981),
      'Study': const Color(0xFFF59E0B),
      'Health': const Color(0xFFEC4899),
      'Other': const Color(0xFF8B5CF6),
    };

    final color = colors[category] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBar(String day, double height, double completedHeight, int count) {
    return Flexible(
      child: SizedBox(
        height: 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667EEA),
                  ),
                ),
              ),
            Container(
              width: 28,
              height: height.clamp(15.0, 120.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF10B981),
                    const Color(0xFF667EEA),
                  ],
                  stops: [
                    completedHeight / height.clamp(15.0, 120.0),
                    completedHeight / height.clamp(15.0, 120.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              day,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayKey(DateTime date) {
    final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
    return weekday;
  }
}

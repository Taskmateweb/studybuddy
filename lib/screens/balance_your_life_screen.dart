import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/prayer_time_model.dart';
import '../services/prayer_service.dart';
import '../services/prayer_notification_service.dart';
import 'prayer_settings_screen.dart';

class BalanceYourLifeScreen extends StatefulWidget {
  const BalanceYourLifeScreen({super.key});

  @override
  State<BalanceYourLifeScreen> createState() => _BalanceYourLifeScreenState();
}

class _BalanceYourLifeScreenState extends State<BalanceYourLifeScreen> with SingleTickerProviderStateMixin {
  final PrayerService _prayerService = PrayerService();
  final PrayerNotificationService _notificationService = PrayerNotificationService();
  
  DailyPrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String? _error;
  Timer? _countdownTimer;
  Duration? _timeUntilNext;
  String? _motivationalQuote;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _loadPrayerTimes();
    _loadMotivationalQuote();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final times = await _prayerService.getTodayPrayerTimes();
      
      if (mounted) {
        setState(() {
          _prayerTimes = times;
          _isLoading = false;
        });

        // Start countdown timer
        _startCountdownTimer();

        // Schedule notifications
        if (times != null) {
          final settings = await _notificationService.loadSettings();
          await _notificationService.schedulePrayerNotifications(times, settings);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _loadMotivationalQuote() {
    final quotes = _prayerService.getMotivationalQuotes();
    setState(() {
      _motivationalQuote = quotes[math.Random().nextInt(quotes.length)];
    });
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTimes != null && mounted) {
        setState(() {
          _timeUntilNext = _prayerTimes!.timeUntilNextPrayer;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF10B981).withOpacity(0.1),
              const Color(0xFF3B82F6).withOpacity(0.1),
              const Color(0xFFF59E0B).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingState()
              : _error != null
                  ? _buildErrorState()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading prayer times...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load Prayer Times',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Please check your location settings',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadPrayerTimes,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_prayerTimes == null) {
      return const Center(child: Text('No prayer times available'));
    }

    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildMotivationalQuote(),
              _buildNextPrayerCard(),
              _buildPrayerTimesList(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981),
                const Color(0xFF059669),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.mosque_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Balance Your Life',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _prayerTimes?.location ?? 'Your Location',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrayerSettingsScreen(
                  prayerTimes: _prayerTimes!,
                  onSettingsChanged: () {
                    _loadPrayerTimes(); // Reload to update notifications
                  },
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: _loadPrayerTimes,
        ),
      ],
    );
  }

  Widget _buildMotivationalQuote() {
    if (_motivationalQuote == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: const Color(0xFFF59E0B),
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _motivationalQuote!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    final nextPrayer = _prayerTimes!.nextPrayer;
    
    if (nextPrayer == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'All Prayers Completed',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'May Allah accept your prayers',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981),
                const Color(0xFF059669),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3 + (_pulseController.value * 0.2)),
                blurRadius: 20 + (_pulseController.value * 10),
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nextPrayer.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Prayer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        nextPrayer.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        nextPrayer.arabicName,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      nextPrayer.formattedTime,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_timeUntilNext != null)
                Column(
                  children: [
                    const Text(
                      'Time Remaining',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _prayerService.getCountdownString(_timeUntilNext),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerTimesList() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
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
                  Icons.calendar_today_rounded,
                  color: const Color(0xFF10B981),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Today\'s Prayer Times',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ..._prayerTimes!.allTimes.map((prayer) => _buildPrayerTimeItem(prayer)),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeItem(PrayerTime prayer) {
    final isNext = prayer.isNext;
    final isPassed = prayer.time.isBefore(DateTime.now()) && !isNext;

    return Container(
      decoration: BoxDecoration(
        color: isNext 
            ? const Color(0xFF10B981).withOpacity(0.1) 
            : isPassed
                ? Colors.grey.shade50
                : Colors.white,
        border: Border(
          left: BorderSide(
            color: isNext ? const Color(0xFF10B981) : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isNext 
                ? const Color(0xFF10B981).withOpacity(0.2)
                : isPassed
                    ? Colors.grey.shade100
                    : const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              prayer.icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                prayer.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                  color: isPassed ? Colors.grey.shade500 : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                prayer.arabicName,
                style: TextStyle(
                  fontSize: 14,
                  color: isPassed ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isNext
                ? const Color(0xFF10B981)
                : isPassed
                    ? Colors.grey.shade200
                    : const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            prayer.formattedTime,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isNext 
                  ? Colors.white
                  : isPassed
                      ? Colors.grey.shade500
                      : const Color(0xFF3B82F6),
            ),
          ),
        ),
      ),
    );
  }
}

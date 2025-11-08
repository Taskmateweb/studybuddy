import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Create a new activity
  Future<String> createActivity({
    required String title,
    required String category,
    required int durationMinutes,
    required DateTime date,
    String? notes,
    String? mood,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final activity = Activity(
      id: '',
      userId: _userId!,
      title: title,
      category: category,
      durationMinutes: durationMinutes,
      date: date,
      notes: notes,
      mood: mood,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore.collection('activities').add(activity.toMap());
    return docRef.id;
  }

  // Get all activities for the current user
  Stream<List<Activity>> getUserActivities() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final activities = snapshot.docs.map((doc) {
        return Activity.fromMap(doc.id, doc.data());
      }).toList();
      
      // Sort in memory instead of Firestore to avoid index requirement
      activities.sort((a, b) => b.date.compareTo(a.date));
      return activities;
    });
  }

  // Get activities by date range
  Stream<List<Activity>> getActivitiesByDateRange(DateTime start, DateTime end) {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: _userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
      final activities = snapshot.docs.map((doc) {
        return Activity.fromMap(doc.id, doc.data());
      }).toList();
      
      // Sort in memory to avoid index requirement
      activities.sort((a, b) => b.date.compareTo(a.date));
      return activities;
    });
  }

  // Get activities by category
  Stream<List<Activity>> getActivitiesByCategory(String category) {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: _userId)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final activities = snapshot.docs.map((doc) {
        return Activity.fromMap(doc.id, doc.data());
      }).toList();
      
      // Sort in memory to avoid index requirement
      activities.sort((a, b) => b.date.compareTo(a.date));
      return activities;
    });
  }

  // Get today's activities
  Stream<List<Activity>> getTodayActivities() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return getActivitiesByDateRange(startOfDay, endOfDay);
  }

  // Quick method for home screen - gets today's activities without sorting
  // Fetches user's activities without date filtering to avoid Firestore composite index requirements
  Future<Map<String, dynamic>> getTodayActivitiesQuick() async {
    if (_userId == null) {
      return {
        'todayCount': 0,
        'todayMinutes': 0,
        'categoryStats': <String, int>{},
      };
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    try {
      // Query only by userId (no date filter) to avoid composite index requirement
      // Limit to most recent 100 activities for performance
      final snapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: _userId)
          .limit(100)
          .get();

      // Filter to only today's activities in memory
      final activities = snapshot.docs.map((doc) {
        return Activity.fromMap(doc.id, doc.data());
      }).where((activity) {
        return (activity.date.isAfter(startOfDay) || activity.date.isAtSameMomentAs(startOfDay)) &&
               (activity.date.isBefore(endOfDay) || activity.date.isAtSameMomentAs(endOfDay));
      }).toList();

      int totalMinutes = 0;
      Map<String, int> categoryStats = {};

      for (var activity in activities) {
        totalMinutes += activity.durationMinutes;
        categoryStats[activity.category] = 
            (categoryStats[activity.category] ?? 0) + activity.durationMinutes;
      }

      return {
        'todayCount': activities.length,
        'todayMinutes': totalMinutes,
        'categoryStats': categoryStats,
      };
    } catch (e) {
      debugPrint('Error getting today activities: $e');
      return {
        'todayCount': 0,
        'todayMinutes': 0,
        'categoryStats': <String, int>{},
      };
    }
  }

  // Get today's summary for home screen (lightweight stream that updates in real-time)
  // Fetches user's activities without date filtering to avoid composite index requirement
  Stream<Map<String, dynamic>> getTodaySummary() {
    if (_userId == null) {
      return Stream.value({
        'todayCount': 0,
        'todayMinutes': 0,
        'categoryStats': <String, int>{},
      });
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Query only by userId (no date filter) to avoid composite index requirement
    // Limit to most recent 100 activities for performance
    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: _userId)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      // Filter to only today's activities in memory
      final activities = snapshot.docs.map((doc) {
        return Activity.fromMap(doc.id, doc.data());
      }).where((activity) {
        return (activity.date.isAfter(startOfDay) || activity.date.isAtSameMomentAs(startOfDay)) &&
               (activity.date.isBefore(endOfDay) || activity.date.isAtSameMomentAs(endOfDay));
      }).toList();

      int totalMinutes = 0;
      Map<String, int> categoryStats = {};

      for (var activity in activities) {
        totalMinutes += activity.durationMinutes;
        categoryStats[activity.category] = 
            (categoryStats[activity.category] ?? 0) + activity.durationMinutes;
      }

      return {
        'todayCount': activities.length,
        'todayMinutes': totalMinutes,
        'categoryStats': categoryStats,
      };
    });
  }

  // Update activity
  Future<void> updateActivity(Activity activity) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('activities')
        .doc(activity.id)
        .update(activity.toMap());
  }

  // Delete activity
  Future<void> deleteActivity(String activityId) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore.collection('activities').doc(activityId).delete();
  }

  // Get statistics
  Future<Map<String, dynamic>> getStats() async {
    if (_userId == null) return {};

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    final allActivities = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: _userId)
        .get();

    final activities = allActivities.docs
        .map((doc) => Activity.fromMap(doc.id, doc.data()))
        .toList();

    // Today's stats
    final todayActivities = activities.where((a) {
      final activityDate = DateTime(a.date.year, a.date.month, a.date.day);
      return activityDate == startOfDay;
    }).toList();

    // Week's stats
    final weekActivities = activities.where((a) => a.date.isAfter(startOfWeek)).toList();

    // Month's stats
    final monthActivities = activities.where((a) => a.date.isAfter(startOfMonth)).toList();

    // Category breakdown
    final categoryStats = <String, int>{};
    for (var activity in activities) {
      categoryStats[activity.category] = 
          (categoryStats[activity.category] ?? 0) + activity.durationMinutes;
    }

    return {
      'todayCount': todayActivities.length,
      'todayMinutes': todayActivities.fold<int>(0, (sum, a) => sum + a.durationMinutes),
      'weekCount': weekActivities.length,
      'weekMinutes': weekActivities.fold<int>(0, (sum, a) => sum + a.durationMinutes),
      'monthCount': monthActivities.length,
      'monthMinutes': monthActivities.fold<int>(0, (sum, a) => sum + a.durationMinutes),
      'totalCount': activities.length,
      'totalMinutes': activities.fold<int>(0, (sum, a) => sum + a.durationMinutes),
      'categoryStats': categoryStats,
    };
  }

  // Get streak (consecutive days with activities)
  Future<int> getStreak() async {
    if (_userId == null) return 0;

    // Use current date/time
    final now = DateTime.now();

    // To avoid requiring a composite index (userId + date order),
    // fetch only activities from the past year using a single-field
    // range query on `date` and sort in memory.
    final oneYearAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 365));

    final snapshot = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: _userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(oneYearAgo))
        .get();

    if (snapshot.docs.isEmpty) return 0;

    final activities = snapshot.docs
        .map((doc) => Activity.fromMap(doc.id, doc.data()))
        .toList();

    // Sort in memory by date descending
    activities.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    var checkDate = DateTime(now.year, now.month, now.day);

    for (var i = 0; i < 365; i++) {
      final hasActivity = activities.any((a) {
        final activityDate = DateTime(a.date.year, a.date.month, a.date.day);
        return activityDate == checkDate;
      });

      if (hasActivity) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Allow one day grace if checking today
        if (i == 0 && checkDate == DateTime(now.year, now.month, now.day)) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }

    return streak;
  }
}

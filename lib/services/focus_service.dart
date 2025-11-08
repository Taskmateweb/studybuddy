import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/focus_session_model.dart';

class FocusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Create a new focus session
  Future<String> createFocusSession({
    String? taskId,
    String? taskTitle,
    int duration = 25,
    int focusTime = 25,
    int breakTime = 5,
    int longBreakTime = 15,
    int sessionsBeforeLongBreak = 4,
  }) async {
    final sessionId = _firestore.collection('focus_sessions').doc().id;
    
    final session = FocusSession(
      id: sessionId,
      userId: _userId,
      taskId: taskId,
      taskTitle: taskTitle,
      duration: duration,
      focusTime: focusTime,
      breakTime: breakTime,
      longBreakTime: longBreakTime,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak,
      startTime: DateTime.now(),
      status: 'focus',
    );

    await _firestore
        .collection('focus_sessions')
        .doc(sessionId)
        .set(session.toMap());

    return sessionId;
  }

  // Update session status
  Future<void> updateSessionStatus(String sessionId, String status) async {
    await _firestore.collection('focus_sessions').doc(sessionId).update({
      'status': status,
    });
  }

  // Complete a pomodoro
  Future<void> completePomodoro(String sessionId, int completedCount) async {
    await _firestore.collection('focus_sessions').doc(sessionId).update({
      'completedPomodoros': completedCount,
    });
  }

  // End session
  Future<void> endSession(String sessionId) async {
    await _firestore.collection('focus_sessions').doc(sessionId).update({
      'endTime': Timestamp.fromDate(DateTime.now()),
      'isCompleted': true,
      'status': 'completed',
    });
  }

  // Get active session
  Stream<FocusSession?> getActiveSession() {
    return _firestore
        .collection('focus_sessions')
        .where('userId', isEqualTo: _userId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('startTime', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return FocusSession.fromMap(snapshot.docs.first.data());
    });
  }

  // Get all sessions
  Stream<List<FocusSession>> getAllSessions() {
    return _firestore
        .collection('focus_sessions')
        .where('userId', isEqualTo: _userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FocusSession.fromMap(doc.data()))
          .toList();
    });
  }

  // Get today's sessions
  Stream<List<FocusSession>> getTodaySessions() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    print('📊 getTodaySessions - userId: $_userId');
    print('📊 getTodaySessions - startOfDay: $startOfDay');
    
    return _firestore
        .collection('focus_sessions')
        .where('userId', isEqualTo: _userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      print('📊 getTodaySessions - docs count: ${snapshot.docs.length}');
      final sessions = snapshot.docs
          .map((doc) {
            print('📊 Session doc: ${doc.id}, data: ${doc.data()}');
            return FocusSession.fromMap(doc.data());
          })
          .toList();
      print('📊 getTodaySessions - parsed sessions: ${sessions.length}');
      return sessions;
    });
  }

  // Get stats
  Future<Map<String, dynamic>> getStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    // Fetch ALL of today's sessions (completed + in-progress) so UI stats match Study Hours card
    final querySnapshot = await _firestore
        .collection('focus_sessions')
        .where('userId', isEqualTo: _userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('startTime', descending: true)
        .get();

    int totalPomodoros = 0; // Sum of completed pomodoros across all sessions
    int totalMinutes = 0;   // Completed minutes + elapsed minutes of active sessions (clamped to duration)
    int completedSessions = 0;

    final now = DateTime.now();

    for (var doc in querySnapshot.docs) {
      final session = FocusSession.fromMap(doc.data());
      totalPomodoros += session.completedPomodoros;
      if (session.isCompleted && session.endTime != null) {
        // Use actual duration between start & end
        totalMinutes += session.endTime!.difference(session.startTime).inMinutes;
        completedSessions += 1;
      } else {
        // Active / in-progress session: count elapsed time so far (capped by planned duration)
        final elapsed = now.difference(session.startTime).inMinutes;
        final clamped = elapsed.clamp(0, session.duration);
        totalMinutes += clamped;
      }
    }

    return {
      'todayPomodoros': totalPomodoros,
      'todayMinutes': totalMinutes,
      'todaySessions': completedSessions, // Keep "sessions" meaning completed sessions for consistency
      'todayTotalSessions': querySnapshot.docs.length, // Optional: total (completed + active)
    };
  }

  // Get task-specific statistics
  Future<Map<String, Map<String, dynamic>>> getTaskStats() async {
  // Include both completed and in-progress sessions to reflect ongoing focus work
  final sessions = await _firestore
    .collection('focus_sessions')
    .where('userId', isEqualTo: _userId)
    .orderBy('startTime', descending: true)
    .get();

    Map<String, Map<String, dynamic>> taskStats = {};

    for (var doc in sessions.docs) {
      final session = FocusSession.fromMap(doc.data());
      
      if (session.taskId != null && session.taskTitle != null) {
        final taskId = session.taskId!;
        
        if (!taskStats.containsKey(taskId)) {
          taskStats[taskId] = {
            'taskTitle': session.taskTitle,
            'sessionCount': 0,
            'totalMinutes': 0,
            'totalPomodoros': 0,
          };
        }
        
        // Count every session (completed or active) toward sessionCount
        taskStats[taskId]!['sessionCount'] = (taskStats[taskId]!['sessionCount'] as int) + 1;
        taskStats[taskId]!['totalPomodoros'] = (taskStats[taskId]!['totalPomodoros'] as int) + session.completedPomodoros;

        // Minutes calculation: completed => actual; in-progress => elapsed (capped at planned duration)
        int addMinutes = 0;
        if (session.isCompleted && session.endTime != null) {
          addMinutes = session.endTime!.difference(session.startTime).inMinutes;
        } else {
          final elapsed = DateTime.now().difference(session.startTime).inMinutes;
          addMinutes = elapsed.clamp(0, session.duration);
        }
        taskStats[taskId]!['totalMinutes'] = (taskStats[taskId]!['totalMinutes'] as int) + addMinutes;
      }
    }

    return taskStats;
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    await _firestore.collection('focus_sessions').doc(sessionId).delete();
  }
}

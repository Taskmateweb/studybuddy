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
    
    return _firestore
        .collection('focus_sessions')
        .where('userId', isEqualTo: _userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FocusSession.fromMap(doc.data()))
          .toList();
    });
  }

  // Get stats
  Future<Map<String, dynamic>> getStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final todaySessions = await _firestore
        .collection('focus_sessions')
        .where('userId', isEqualTo: _userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('isCompleted', isEqualTo: true)
        .get();

    int totalPomodoros = 0;
    int totalMinutes = 0;

    for (var doc in todaySessions.docs) {
      final session = FocusSession.fromMap(doc.data());
      totalPomodoros += session.completedPomodoros;
      if (session.endTime != null) {
        totalMinutes += session.endTime!.difference(session.startTime).inMinutes;
      }
    }

    return {
      'todayPomodoros': totalPomodoros,
      'todayMinutes': totalMinutes,
      'todaySessions': todaySessions.docs.length,
    };
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    await _firestore.collection('focus_sessions').doc(sessionId).delete();
  }
}

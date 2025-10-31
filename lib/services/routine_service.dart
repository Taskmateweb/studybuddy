import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/routine_model.dart';

class RoutineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Get all routines for current user
  Stream<List<RoutineItem>> getUserRoutines() {
    return _firestore
        .collection('routines')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final routines = snapshot.docs.map((doc) {
        return RoutineItem.fromMap(doc.data(), doc.id);
      }).toList();

      // Sort by start time
      routines.sort((a, b) {
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });

      return routines;
    });
  }

  // Get today's routines
  Stream<List<RoutineItem>> getTodaysRoutines() {
    final today = DateTime.now().weekday;
    
    return _firestore
        .collection('routines')
        .where('userId', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final allRoutines = snapshot.docs.map((doc) {
        return RoutineItem.fromMap(doc.data(), doc.id);
      }).toList();

      // Filter for today
      final todaysRoutines = allRoutines.where((routine) {
        return routine.daysOfWeek.contains(today);
      }).toList();

      // Sort by start time
      todaysRoutines.sort((a, b) {
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });

      return todaysRoutines;
    });
  }

  // Add a new routine
  Future<void> addRoutine({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    required List<int> daysOfWeek,
    String? subject,
    String? location,
  }) async {
    if (_userId.isEmpty) throw Exception('User not logged in');

    final routine = RoutineItem(
      id: '',
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      userId: _userId,
      daysOfWeek: daysOfWeek,
      subject: subject,
      location: location,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('routines').add(routine.toMap());
  }

  // Update routine
  Future<void> updateRoutine(RoutineItem routine) async {
    await _firestore
        .collection('routines')
        .doc(routine.id)
        .update(routine.toMap());
  }

  // Toggle routine active status
  Future<void> toggleRoutineStatus(String routineId, bool isActive) async {
    await _firestore.collection('routines').doc(routineId).update({
      'isActive': !isActive,
    });
  }

  // Delete routine
  Future<void> deleteRoutine(String routineId) async {
    await _firestore.collection('routines').doc(routineId).delete();
  }

  // Get routine count
  Future<int> getRoutineCount() async {
    final snapshot = await _firestore
        .collection('routines')
        .where('userId', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.length;
  }

  // Check if there's a conflict with existing routines
  Future<bool> hasTimeConflict({
    required DateTime startTime,
    required DateTime endTime,
    required List<int> daysOfWeek,
    String? excludeRoutineId,
  }) async {
    final snapshot = await _firestore
        .collection('routines')
        .where('userId', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .get();

    final routines = snapshot.docs
        .map((doc) => RoutineItem.fromMap(doc.data(), doc.id))
        .where((r) => r.id != excludeRoutineId)
        .toList();

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    for (final routine in routines) {
      // Check if days overlap
      final hasCommonDay = routine.daysOfWeek.any((day) => daysOfWeek.contains(day));
      if (!hasCommonDay) continue;

      final routineStart = routine.startTime.hour * 60 + routine.startTime.minute;
      final routineEnd = routine.endTime.hour * 60 + routine.endTime.minute;

      // Check time overlap
      if ((startMinutes < routineEnd && endMinutes > routineStart)) {
        return true;
      }
    }

    return false;
  }

  // Get current routine (if any)
  Future<RoutineItem?> getCurrentRoutine() async {
    final now = DateTime.now();
    final today = now.weekday;
    final currentMinutes = now.hour * 60 + now.minute;

    final snapshot = await _firestore
        .collection('routines')
        .where('userId', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .get();

    final routines = snapshot.docs
        .map((doc) => RoutineItem.fromMap(doc.data(), doc.id))
        .where((r) => r.daysOfWeek.contains(today))
        .toList();

    for (final routine in routines) {
      final startMinutes = routine.startTime.hour * 60 + routine.startTime.minute;
      final endMinutes = routine.endTime.hour * 60 + routine.endTime.minute;

      if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
        return routine;
      }
    }

    return null;
  }

  // Get next routine
  Future<RoutineItem?> getNextRoutine() async {
    final now = DateTime.now();
    final today = now.weekday;
    final currentMinutes = now.hour * 60 + now.minute;

    final snapshot = await _firestore
        .collection('routines')
        .where('userId', isEqualTo: _userId)
        .where('isActive', isEqualTo: true)
        .get();

    final routines = snapshot.docs
        .map((doc) => RoutineItem.fromMap(doc.data(), doc.id))
        .toList();

    // Find next routine today
    final todaysRoutines = routines
        .where((r) => r.daysOfWeek.contains(today))
        .where((r) {
          final startMinutes = r.startTime.hour * 60 + r.startTime.minute;
          return startMinutes > currentMinutes;
        })
        .toList();

    if (todaysRoutines.isNotEmpty) {
      todaysRoutines.sort((a, b) {
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
      return todaysRoutines.first;
    }

    // If no routine today, find next day's first routine
    for (int i = 1; i <= 7; i++) {
      final nextDay = (today + i) % 7;
      final nextDayRoutines = routines
          .where((r) => r.daysOfWeek.contains(nextDay == 0 ? 7 : nextDay))
          .toList();

      if (nextDayRoutines.isNotEmpty) {
        nextDayRoutines.sort((a, b) {
          final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
          final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
          return aMinutes.compareTo(bMinutes);
        });
        return nextDayRoutines.first;
      }
    }

    return null;
  }
}

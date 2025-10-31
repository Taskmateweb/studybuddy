import 'package:cloud_firestore/cloud_firestore.dart';

class FocusSession {
  final String id;
  final String userId;
  final String? taskId;
  final String? taskTitle;
  final int duration; // in minutes
  final int focusTime; // Pomodoro focus duration (default 25)
  final int breakTime; // Pomodoro break duration (default 5)
  final int longBreakTime; // Long break duration (default 15)
  final int sessionsBeforeLongBreak; // Sessions before long break (default 4)
  final DateTime startTime;
  final DateTime? endTime;
  final int completedPomodoros;
  final bool isCompleted;
  final String status; // 'focus', 'break', 'long_break', 'paused', 'completed'

  FocusSession({
    required this.id,
    required this.userId,
    this.taskId,
    this.taskTitle,
    required this.duration,
    this.focusTime = 25,
    this.breakTime = 5,
    this.longBreakTime = 15,
    this.sessionsBeforeLongBreak = 4,
    required this.startTime,
    this.endTime,
    this.completedPomodoros = 0,
    this.isCompleted = false,
    this.status = 'focus',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'duration': duration,
      'focusTime': focusTime,
      'breakTime': breakTime,
      'longBreakTime': longBreakTime,
      'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'completedPomodoros': completedPomodoros,
      'isCompleted': isCompleted,
      'status': status,
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      taskId: map['taskId'],
      taskTitle: map['taskTitle'],
      duration: map['duration'] ?? 25,
      focusTime: map['focusTime'] ?? 25,
      breakTime: map['breakTime'] ?? 5,
      longBreakTime: map['longBreakTime'] ?? 15,
      sessionsBeforeLongBreak: map['sessionsBeforeLongBreak'] ?? 4,
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null ? (map['endTime'] as Timestamp).toDate() : null,
      completedPomodoros: map['completedPomodoros'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      status: map['status'] ?? 'focus',
    );
  }

  FocusSession copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? taskTitle,
    int? duration,
    int? focusTime,
    int? breakTime,
    int? longBreakTime,
    int? sessionsBeforeLongBreak,
    DateTime? startTime,
    DateTime? endTime,
    int? completedPomodoros,
    bool? isCompleted,
    String? status,
  }) {
    return FocusSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      duration: duration ?? this.duration,
      focusTime: focusTime ?? this.focusTime,
      breakTime: breakTime ?? this.breakTime,
      longBreakTime: longBreakTime ?? this.longBreakTime,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
    );
  }

  int get totalMinutes => duration;
  
  String get statusLabel {
    switch (status) {
      case 'focus':
        return 'Focus Time';
      case 'break':
        return 'Short Break';
      case 'long_break':
        return 'Long Break';
      case 'paused':
        return 'Paused';
      case 'completed':
        return 'Completed';
      default:
        return 'Focus Time';
    }
  }
}

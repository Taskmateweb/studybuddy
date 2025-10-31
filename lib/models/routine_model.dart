class RoutineItem {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String userId;
  final List<int> daysOfWeek; // 1=Monday, 7=Sunday
  final String? subject;
  final String? location;
  final bool isActive;
  final DateTime createdAt;

  RoutineItem({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.userId,
    required this.daysOfWeek,
    this.subject,
    this.location,
    this.isActive = true,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'userId': userId,
      'daysOfWeek': daysOfWeek,
      'subject': subject,
      'location': location,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory RoutineItem.fromMap(Map<String, dynamic> map, String id) {
    return RoutineItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      userId: map['userId'] ?? '',
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      subject: map['subject'],
      location: map['location'],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Copy with updated values
  RoutineItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? userId,
    List<int>? daysOfWeek,
    String? subject,
    String? location,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RoutineItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      userId: userId ?? this.userId,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      subject: subject ?? this.subject,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get duration in minutes
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  // Check if routine is active today
  bool isActiveToday() {
    final today = DateTime.now().weekday;
    return daysOfWeek.contains(today) && isActive;
  }

  // Get formatted time range
  String get timeRange {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  // Get days as string
  String get daysString {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (daysOfWeek.length == 7) return 'Every Day';
    if (daysOfWeek.length == 5 && !daysOfWeek.contains(6) && !daysOfWeek.contains(7)) {
      return 'Weekdays';
    }
    if (daysOfWeek.length == 2 && daysOfWeek.contains(6) && daysOfWeek.contains(7)) {
      return 'Weekend';
    }
    return daysOfWeek.map((day) => dayNames[day - 1]).join(', ');
  }
}

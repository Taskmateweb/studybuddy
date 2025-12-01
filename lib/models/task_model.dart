class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  // Optional scheduled window
  final DateTime? startAt; // combined date + start time
  final DateTime? endAt;   // combined date + end time
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? category;
  final int priority; // 1: Low, 2: Medium, 3: High

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.startAt,
    this.endAt,
    required this.isCompleted,
    required this.userId,
    required this.createdAt,
    this.completedAt,
    this.category,
    this.priority = 2,
  });

  // Convert Task to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'startAt': startAt?.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'category': category,
      'priority': priority,
    };
  }

  // Create Task from Firestore document
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      startAt: map['startAt'] != null ? DateTime.parse(map['startAt']) : null,
      endAt: map['endAt'] != null ? DateTime.parse(map['endAt']) : null,
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      category: map['category'],
      priority: map['priority'] ?? 2,
    );
  }

  // Create a copy with updated values
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? startAt,
    DateTime? endAt,
    bool? isCompleted,
    String? userId,
    DateTime? createdAt,
    DateTime? completedAt,
    String? category,
    int? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }
}

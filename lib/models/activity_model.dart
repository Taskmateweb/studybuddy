import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String userId;
  final String title;
  final String category; // sports, music, art, reading, etc.
  final int durationMinutes;
  final DateTime date;
  final String? notes;
  final String? mood; // happy, neutral, tired, energized
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.date,
    this.notes,
    this.mood,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'category': category,
      'durationMinutes': durationMinutes,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'mood': mood,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Activity.fromMap(String id, Map<String, dynamic> map) {
    return Activity(
      id: id,
      userId: map['userId'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      durationMinutes: map['durationMinutes'] as int,
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      mood: map['mood'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Activity copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    int? durationMinutes,
    DateTime? date,
    String? notes,
    String? mood,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ActivityCategory {
  final String name;
  final String icon;
  final String color;
  final String description;

  const ActivityCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  static const List<ActivityCategory> categories = [
    ActivityCategory(
      name: 'Sports',
      icon: 'sports_soccer',
      color: '4CAF50',
      description: 'Physical activities and sports',
    ),
    ActivityCategory(
      name: 'Music',
      icon: 'music_note',
      color: 'FF9800',
      description: 'Playing instruments and music practice',
    ),
    ActivityCategory(
      name: 'Art',
      icon: 'palette',
      color: 'E91E63',
      description: 'Drawing, painting, and creative arts',
    ),
    ActivityCategory(
      name: 'Reading',
      icon: 'menu_book',
      color: '9C27B0',
      description: 'Reading books and literature',
    ),
    ActivityCategory(
      name: 'Dance',
      icon: 'celebration',
      color: 'FF5722',
      description: 'Dance and choreography',
    ),
    ActivityCategory(
      name: 'Photography',
      icon: 'camera_alt',
      color: '00BCD4',
      description: 'Photography and videography',
    ),
    ActivityCategory(
      name: 'Coding',
      icon: 'code',
      color: '3F51B5',
      description: 'Programming and tech projects',
    ),
    ActivityCategory(
      name: 'Volunteering',
      icon: 'volunteer_activism',
      color: 'FFC107',
      description: 'Community service and volunteering',
    ),
  ];
}

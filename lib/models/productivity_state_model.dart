import 'package:cloud_firestore/cloud_firestore.dart';

/// Productivity State Model
/// Represents user's daily productivity metrics and state
class ProductivityState {
  final String id;
  final String userId;
  final DateTime date;
  final double score; // 0-100
  final ProductivityLevel level;
  
  // Metrics used for calculation
  final int tasksCompleted;
  final int tasksAdded;
  final int focusSessionsCompleted;
  final int totalFocusMinutes;
  final double routineCompletionRate; // 0-100
  final int youtubeDistractedMinutes; // minutes spent on non-educational content
  final int missedTasks;
  final double prayerCompletionRate; // 0-100 (optional)
  
  // Breakdown scores
  final double taskScore;
  final double focusScore;
  final double routineScore;
  final double distractionScore;
  final double consistencyScore;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductivityState({
    required this.id,
    required this.userId,
    required this.date,
    required this.score,
    required this.level,
    required this.tasksCompleted,
    required this.tasksAdded,
    required this.focusSessionsCompleted,
    required this.totalFocusMinutes,
    required this.routineCompletionRate,
    required this.youtubeDistractedMinutes,
    required this.missedTasks,
    required this.prayerCompletionRate,
    required this.taskScore,
    required this.focusScore,
    required this.routineScore,
    required this.distractionScore,
    required this.consistencyScore,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'score': score,
      'level': level.name,
      'tasksCompleted': tasksCompleted,
      'tasksAdded': tasksAdded,
      'focusSessionsCompleted': focusSessionsCompleted,
      'totalFocusMinutes': totalFocusMinutes,
      'routineCompletionRate': routineCompletionRate,
      'youtubeDistractedMinutes': youtubeDistractedMinutes,
      'missedTasks': missedTasks,
      'prayerCompletionRate': prayerCompletionRate,
      'taskScore': taskScore,
      'focusScore': focusScore,
      'routineScore': routineScore,
      'distractionScore': distractionScore,
      'consistencyScore': consistencyScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory ProductivityState.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductivityState(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      score: (data['score'] ?? 0).toDouble(),
      level: ProductivityLevel.fromString(data['level'] ?? 'low'),
      tasksCompleted: data['tasksCompleted'] ?? 0,
      tasksAdded: data['tasksAdded'] ?? 0,
      focusSessionsCompleted: data['focusSessionsCompleted'] ?? 0,
      totalFocusMinutes: data['totalFocusMinutes'] ?? 0,
      routineCompletionRate: (data['routineCompletionRate'] ?? 0).toDouble(),
      youtubeDistractedMinutes: data['youtubeDistractedMinutes'] ?? 0,
      missedTasks: data['missedTasks'] ?? 0,
      prayerCompletionRate: (data['prayerCompletionRate'] ?? 0).toDouble(),
      taskScore: (data['taskScore'] ?? 0).toDouble(),
      focusScore: (data['focusScore'] ?? 0).toDouble(),
      routineScore: (data['routineScore'] ?? 0).toDouble(),
      distractionScore: (data['distractionScore'] ?? 0).toDouble(),
      consistencyScore: (data['consistencyScore'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  ProductivityState copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? score,
    ProductivityLevel? level,
    int? tasksCompleted,
    int? tasksAdded,
    int? focusSessionsCompleted,
    int? totalFocusMinutes,
    double? routineCompletionRate,
    int? youtubeDistractedMinutes,
    int? missedTasks,
    double? prayerCompletionRate,
    double? taskScore,
    double? focusScore,
    double? routineScore,
    double? distractionScore,
    double? consistencyScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductivityState(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      score: score ?? this.score,
      level: level ?? this.level,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      tasksAdded: tasksAdded ?? this.tasksAdded,
      focusSessionsCompleted: focusSessionsCompleted ?? this.focusSessionsCompleted,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      routineCompletionRate: routineCompletionRate ?? this.routineCompletionRate,
      youtubeDistractedMinutes: youtubeDistractedMinutes ?? this.youtubeDistractedMinutes,
      missedTasks: missedTasks ?? this.missedTasks,
      prayerCompletionRate: prayerCompletionRate ?? this.prayerCompletionRate,
      taskScore: taskScore ?? this.taskScore,
      focusScore: focusScore ?? this.focusScore,
      routineScore: routineScore ?? this.routineScore,
      distractionScore: distractionScore ?? this.distractionScore,
      consistencyScore: consistencyScore ?? this.consistencyScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Productivity Level Enum with color and description
enum ProductivityLevel {
  highlyProductive,
  productive,
  moderate,
  low,
  needsImprovement;

  String get displayName {
    switch (this) {
      case ProductivityLevel.highlyProductive:
        return 'Highly Productive';
      case ProductivityLevel.productive:
        return 'Productive';
      case ProductivityLevel.moderate:
        return 'Moderate';
      case ProductivityLevel.low:
        return 'Low';
      case ProductivityLevel.needsImprovement:
        return 'Needs Improvement';
    }
  }

  String get description {
    switch (this) {
      case ProductivityLevel.highlyProductive:
        return 'Outstanding! You\'re crushing your goals! 🔥';
      case ProductivityLevel.productive:
        return 'Great work! Keep up the momentum! 💪';
      case ProductivityLevel.moderate:
        return 'You\'re doing okay. Room for improvement! 📈';
      case ProductivityLevel.low:
        return 'Time to step it up! You can do better! ⚡';
      case ProductivityLevel.needsImprovement:
        return 'Let\'s get back on track! Small steps matter! 🎯';
    }
  }

  String get emoji {
    switch (this) {
      case ProductivityLevel.highlyProductive:
        return '🏆';
      case ProductivityLevel.productive:
        return '⭐';
      case ProductivityLevel.moderate:
        return '👍';
      case ProductivityLevel.low:
        return '📊';
      case ProductivityLevel.needsImprovement:
        return '🎯';
    }
  }

  // Color codes (use with Color(colorValue))
  int get colorValue {
    switch (this) {
      case ProductivityLevel.highlyProductive:
        return 0xFF10B981; // Green
      case ProductivityLevel.productive:
        return 0xFF3B82F6; // Blue
      case ProductivityLevel.moderate:
        return 0xFFF59E0B; // Amber
      case ProductivityLevel.low:
        return 0xFFEF4444; // Red
      case ProductivityLevel.needsImprovement:
        return 0xFF9CA3AF; // Gray
    }
  }

  static ProductivityLevel fromScore(double score) {
    if (score >= 85) return ProductivityLevel.highlyProductive;
    if (score >= 70) return ProductivityLevel.productive;
    if (score >= 50) return ProductivityLevel.moderate;
    if (score >= 30) return ProductivityLevel.low;
    return ProductivityLevel.needsImprovement;
  }

  static ProductivityLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'highlyproductive':
        return ProductivityLevel.highlyProductive;
      case 'productive':
        return ProductivityLevel.productive;
      case 'moderate':
        return ProductivityLevel.moderate;
      case 'low':
        return ProductivityLevel.low;
      default:
        return ProductivityLevel.needsImprovement;
    }
  }
}

/// Productivity Insights - AI-like suggestions
class ProductivityInsight {
  final String title;
  final String description;
  final String actionItem;
  final InsightType type;

  ProductivityInsight({
    required this.title,
    required this.description,
    required this.actionItem,
    required this.type,
  });
}

enum InsightType {
  positive,
  warning,
  suggestion,
  achievement
}

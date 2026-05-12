/// Daily Mission data model
class DailyMission {
  final String id;
  final String title;
  final String description;
  final String type; // 'scanObject', 'findRarity', 'scanType', 'scanCount'
  final dynamic target;
  final int progress;
  final bool completed;
  final DateTime date;
  final int xpReward;

  const DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.progress = 0,
    this.completed = false,
    required this.date,
    this.xpReward = 20,
  });

  double get progressPercent {
    if (target is int && (target as int) > 0) {
      return (progress / (target as int)).clamp(0.0, 1.0);
    }
    return completed ? 1.0 : 0.0;
  }

  factory DailyMission.fromMap(Map<String, dynamic> map) {
    return DailyMission(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'scanCount',
      target: map['target'],
      progress: map['progress'] as int? ?? 0,
      completed: map['completed'] as bool? ?? false,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      xpReward: map['xpReward'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'target': target,
      'progress': progress,
      'completed': completed,
      'date': date.toIso8601String(),
      'xpReward': xpReward,
    };
  }

  DailyMission copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    dynamic target,
    int? progress,
    bool? completed,
    DateTime? date,
    int? xpReward,
  }) {
    return DailyMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      date: date ?? this.date,
      xpReward: xpReward ?? this.xpReward,
    );
  }
}

/// User data model for CreatureLens
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final int level;
  final int xp;
  final int totalCreatures;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastScanDate;
  final List<String> achievements;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl = '',
    this.level = 1,
    this.xp = 0,
    this.totalCreatures = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastScanDate,
    this.achievements = const [],
    required this.createdAt,
  });

  /// XP required to reach the next level
  int get xpToNextLevel => level * 100 + (level ~/ 5) * 50;

  /// Progress towards next level (0.0 - 1.0)
  double get levelProgress => xp / xpToNextLevel;

  /// Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Trainer',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      totalCreatures: map['totalCreatures'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastScanDate: _dateFromMap(map['lastScanDate']),
      achievements: List<String>.from(map['achievements'] ?? []),
      createdAt: _dateFromMap(map['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _dateFromMap(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      final dynamic maybeTimestamp = value;
      final date = maybeTimestamp.toDate();
      if (date is DateTime) return date;
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'level': level,
      'xp': xp,
      'totalCreatures': totalCreatures,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastScanDate': lastScanDate?.toIso8601String(),
      'achievements': achievements,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    int? level,
    int? xp,
    int? totalCreatures,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastScanDate,
    List<String>? achievements,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalCreatures: totalCreatures ?? this.totalCreatures,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastScanDate: lastScanDate ?? this.lastScanDate,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

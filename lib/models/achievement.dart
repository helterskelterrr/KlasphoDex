/// Achievement data model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final AchievementRequirement requirement;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.requirement,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'star',
      requirement: AchievementRequirement.fromMap(
        map['requirement'] as Map<String, dynamic>? ?? {},
      ),
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.tryParse(map['unlockedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'requirement': requirement.toMap(),
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
}

/// Describes what must be fulfilled for an achievement
class AchievementRequirement {
  final String type; // 'totalCreatures', 'streak', 'rarityCollect', etc.
  final int target;
  final String? subType; // e.g., specific rarity or element type

  const AchievementRequirement({
    required this.type,
    required this.target,
    this.subType,
  });

  factory AchievementRequirement.fromMap(Map<String, dynamic> map) {
    return AchievementRequirement(
      type: map['type'] as String? ?? '',
      target: map['target'] as int? ?? 0,
      subType: map['subType'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'type': type, 'target': target, 'subType': subType};
  }
}

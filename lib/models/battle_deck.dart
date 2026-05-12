class BattleDeck {
  static const requiredCardCount = 8;

  final String id;
  final String name;
  final List<String> creatureIds;
  final DateTime updatedAt;
  final bool isActive;

  const BattleDeck({
    required this.id,
    required this.name,
    required this.creatureIds,
    required this.updatedAt,
    this.isActive = true,
  });

  bool get isValid => creatureIds.length == requiredCardCount;

  int get missingCardCount {
    final missing = requiredCardCount - creatureIds.length;
    return missing < 0 ? 0 : missing;
  }

  factory BattleDeck.fromMap(Map<String, dynamic> map) {
    return BattleDeck(
      id: map['id'] as String? ?? 'active-deck',
      name: map['name'] as String? ?? 'Field Deck',
      creatureIds: List<String>.from(map['creatureIds'] ?? const []),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'creatureIds': creatureIds,
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  BattleDeck copyWith({
    String? id,
    String? name,
    List<String>? creatureIds,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return BattleDeck(
      id: id ?? this.id,
      name: name ?? this.name,
      creatureIds: creatureIds ?? this.creatureIds,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

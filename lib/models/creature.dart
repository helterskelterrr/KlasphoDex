import 'package:uuid/uuid.dart';

/// Creature data model — the core entity of CreatureLens
class Creature {
  final String id;
  final String userId;
  final String name;
  final String type; // element type
  final String rarity;
  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final List<CreatureAbility> abilities;
  final String lore;
  final String? imageUrl;
  final String scannedObject;
  final List<String> scannedLabels;
  final DateTime discoveredAt;
  final int evolutionShards;

  const Creature({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.rarity,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.abilities,
    required this.lore,
    this.imageUrl,
    required this.scannedObject,
    this.scannedLabels = const [],
    required this.discoveredAt,
    this.evolutionShards = 0,
  });

  /// Total power = average of all stats
  int get totalPower => ((hp + attack + defense + speed) / 4).round();

  /// Emoji icon for the element type
  String get typeEmoji {
    switch (type.toLowerCase()) {
      case 'fire':
        return '🔥';
      case 'water':
        return '💧';
      case 'earth':
        return '🪨';
      case 'air':
        return '💨';
      case 'electric':
        return '⚡';
      case 'nature':
        return '🌿';
      case 'shadow':
        return '🌑';
      case 'light':
        return '✨';
      default:
        return '🔮';
    }
  }

  /// Rarity star display
  String get rarityStars {
    switch (rarity.toLowerCase()) {
      case 'common':
        return '⭐';
      case 'uncommon':
        return '⭐⭐';
      case 'rare':
        return '⭐⭐⭐';
      case 'epic':
        return '⭐⭐⭐⭐';
      case 'legendary':
        return '⭐⭐⭐⭐⭐';
      default:
        return '⭐';
    }
  }

  /// XP reward for discovering this creature
  int get xpReward {
    switch (rarity.toLowerCase()) {
      case 'common':
        return 10;
      case 'uncommon':
        return 25;
      case 'rare':
        return 50;
      case 'epic':
        return 100;
      case 'legendary':
        return 250;
      default:
        return 10;
    }
  }

  factory Creature.fromMap(Map<String, dynamic> map) {
    final normalizedRarity = _normalizeRarity(map['rarity'] as String?);
    return Creature(
      id: map['id'] as String? ?? const Uuid().v4(),
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown Creature',
      type: map['type'] as String? ?? 'Nature',
      rarity: normalizedRarity,
      hp: _balancedStat(map, 'hp', 50, normalizedRarity),
      attack: _balancedStat(map, 'attack', 50, normalizedRarity),
      defense: _balancedStat(map, 'defense', 50, normalizedRarity),
      speed: _balancedStat(map, 'speed', 50, normalizedRarity),
      abilities:
          (map['abilities'] as List<dynamic>?)
              ?.map(
                (a) => CreatureAbility.fromMap(
                  Map<String, dynamic>.from(a as Map),
                ),
              )
              .toList() ??
          [],
      lore: map['lore'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      scannedObject: map['scannedObject'] as String? ?? '',
      scannedLabels: List<String>.from(map['scannedLabels'] ?? []),
      discoveredAt:
          DateTime.tryParse(map['discoveredAt'] as String? ?? '') ??
          DateTime.now(),
      evolutionShards: map['evolutionShards'] as int? ?? 0,
    );
  }

  static int _intFromMap(Map<String, dynamic> map, String key, int fallback) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static String _normalizeRarity(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'uncommon':
        return 'Uncommon';
      case 'rare':
        return 'Rare';
      case 'epic':
        return 'Epic';
      case 'legendary':
        return 'Legendary';
      case 'common':
      default:
        return 'Common';
    }
  }

  static int _balancedStat(
    Map<String, dynamic> map,
    String key,
    int fallback,
    String rarity,
  ) {
    final raw = _intFromMap(map, key, fallback).clamp(30, 100).toInt();
    final (min, max) = _statBandForRarity(rarity);
    return raw.clamp(min, max).toInt();
  }

  static (int, int) _statBandForRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'uncommon':
        return (40, 78);
      case 'rare':
        return (50, 86);
      case 'epic':
        return (60, 94);
      case 'legendary':
        return (70, 100);
      case 'common':
      default:
        return (30, 70);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'rarity': rarity,
      'hp': hp,
      'attack': attack,
      'defense': defense,
      'speed': speed,
      'abilities': abilities.map((a) => a.toMap()).toList(),
      'lore': lore,
      'imageUrl': imageUrl,
      'scannedObject': scannedObject,
      'scannedLabels': scannedLabels,
      'discoveredAt': discoveredAt.toIso8601String(),
      'evolutionShards': evolutionShards,
    };
  }

  Creature copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? rarity,
    int? hp,
    int? attack,
    int? defense,
    int? speed,
    List<CreatureAbility>? abilities,
    String? lore,
    String? imageUrl,
    String? scannedObject,
    List<String>? scannedLabels,
    DateTime? discoveredAt,
    int? evolutionShards,
  }) {
    return Creature(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      hp: hp ?? this.hp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      speed: speed ?? this.speed,
      abilities: abilities ?? this.abilities,
      lore: lore ?? this.lore,
      imageUrl: imageUrl ?? this.imageUrl,
      scannedObject: scannedObject ?? this.scannedObject,
      scannedLabels: scannedLabels ?? this.scannedLabels,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      evolutionShards: evolutionShards ?? this.evolutionShards,
    );
  }
}

/// A single ability a creature possesses
class CreatureAbility {
  final String name;
  final String description;
  final String type;

  const CreatureAbility({
    required this.name,
    required this.description,
    this.type = 'Normal',
  });

  factory CreatureAbility.fromMap(Map<String, dynamic> map) {
    return CreatureAbility(
      name: map['name'] as String? ?? 'Unknown',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'Normal',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'type': type};
  }
}

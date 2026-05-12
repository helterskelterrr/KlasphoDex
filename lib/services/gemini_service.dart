import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/creature.dart';

class CreatureGenerationRequest {
  const CreatureGenerationRequest({
    required this.labels,
    required this.userLevel,
    required this.streakMultiplier,
    this.imageBase64,
    this.imageMimeType,
  });

  final List<String> labels;
  final int userLevel;
  final int streakMultiplier;
  final String? imageBase64;
  final String? imageMimeType;

  Map<String, dynamic> toMap() {
    final map = {
      'labels': labels,
      'userLevel': userLevel,
      'streakMultiplier': streakMultiplier,
    };
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      map['imageBase64'] = imageBase64!;
      map['imageMimeType'] = imageMimeType ?? 'image/jpeg';
    }
    return map;
  }
}

class CreatureGenerationResponse {
  const CreatureGenerationResponse(this.data);

  final Map<String, dynamic> data;
}

abstract class CreatureGenerationGateway {
  Future<CreatureGenerationResponse> generateCreature(
    CreatureGenerationRequest request,
  );
}

class FirebaseFunctionsCreatureGateway implements CreatureGenerationGateway {
  FirebaseFunctionsCreatureGateway({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<CreatureGenerationResponse> generateCreature(
    CreatureGenerationRequest request,
  ) async {
    final callable = _functions.httpsCallable('generateCreature');
    final result = await callable.call<Map<String, dynamic>>(request.toMap());
    return CreatureGenerationResponse(Map<String, dynamic>.from(result.data));
  }
}

class OpenRouterCreatureGateway implements CreatureGenerationGateway {
  OpenRouterCreatureGateway({required String apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;

  static final Uri _endpoint = Uri.parse(
    'https://openrouter.ai/api/v1/chat/completions',
  );
  static const _modelCandidates = [
    'google/gemma-4-31b-it:free',
    'google/gemma-4-26b-a4b-it:free',
    'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
  ];

  @override
  Future<CreatureGenerationResponse> generateCreature(
    CreatureGenerationRequest request,
  ) async {
    if (_apiKey.isEmpty) {
      throw StateError('OPENROUTER_API_KEY is empty.');
    }

    for (final (index, model) in _modelCandidates.indexed) {
      final response = await _client.post(
        _endpoint,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'X-OpenRouter-Title': 'CreatureLens',
        },
        body: jsonEncode({
          'model': model,
          'messages': _buildMessages(request),
          'temperature': 0.5,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final retryable =
            response.statusCode == 429 || response.statusCode >= 500;
        if (retryable && index < _modelCandidates.length - 1) continue;
        throw StateError(
          'OpenRouter failed for $model with ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw StateError('OpenRouter returned invalid JSON.');
      }
      final choices = decoded['choices'];
      final first = choices is List && choices.isNotEmpty
          ? choices.first
          : null;
      final message = first is Map ? first['message'] : null;
      final content = message is Map ? message['content'] : null;
      if (content is! String) {
        throw StateError('OpenRouter returned no text content.');
      }

      final creaturePayload = _extractJsonObject(content);
      return CreatureGenerationResponse(
        _normalizeCreaturePayload(creaturePayload),
      );
    }

    throw StateError('OpenRouter request failed.');
  }

  static List<Map<String, dynamic>> _buildMessages(
    CreatureGenerationRequest request,
  ) {
    final prompt = _buildCreaturePrompt(request);
    if (request.imageBase64 == null || request.imageBase64!.isEmpty) {
      return [
        {'role': 'user', 'content': prompt},
      ];
    }

    return [
      {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': prompt},
          {
            'type': 'image_url',
            'image_url': {
              'url':
                  'data:${request.imageMimeType ?? 'image/jpeg'};base64,${request.imageBase64}',
            },
          },
        ],
      },
    ];
  }

  static String _buildCreaturePrompt(CreatureGenerationRequest request) {
    return '''You are a fantasy creature designer for CreatureLens.

The user scanned a real-world object and the AI detected these labels: ${request.labels.join(', ')}.
${request.imageBase64 != null && request.imageBase64!.isNotEmpty ? 'A final camera image is attached. Use the image as the source of truth when labels look generic or uncertain.' : ''}

Return ONLY valid JSON with this exact structure:
{
  "name": "Creative creature name",
  "type": "One of: Fire, Water, Earth, Air, Electric, Nature, Shadow, Light",
  "rarity": "One of: Common, Uncommon, Rare, Epic, Legendary",
  "hp": <number 30-100>,
  "attack": <number 20-100>,
  "defense": <number 20-100>,
  "speed": <number 20-100>,
  "abilities": [
    {"name": "Ability Name", "description": "What it does", "type": "Element type"}
  ],
  "lore": "A short, atmospheric backstory paragraph"
}

Rules:
- Creature should be inspired by the scanned object but fantastical.
- Higher stats for rarer creatures.
- User level is ${request.userLevel}.
- Streak multiplier is ${request.streakMultiplier}.
- Generate 2-3 abilities.''';
  }

  static Map<String, dynamic> _extractJsonObject(String text) {
    final codeBlock = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(text);
    final objectMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    final candidate = codeBlock?.group(1) ?? objectMatch?.group(0) ?? text;
    final decoded = jsonDecode(candidate.trim());
    if (decoded is! Map<String, dynamic>) {
      throw StateError('OpenRouter creature JSON was not an object.');
    }
    return decoded;
  }

  static Map<String, dynamic> _normalizeCreaturePayload(
    Map<String, dynamic> payload,
  ) {
    return {
      'name': payload['name'] is String ? payload['name'] : 'Fieldborn Sprite',
      'type': payload['type'] is String ? payload['type'] : 'Nature',
      'rarity': payload['rarity'] is String ? payload['rarity'] : 'Common',
      'hp': payload['hp'],
      'attack': payload['attack'],
      'defense': payload['defense'],
      'speed': payload['speed'],
      'abilities': payload['abilities'] is List ? payload['abilities'] : [],
      'lore': payload['lore'] is String ? payload['lore'] : '',
    };
  }
}

/// Service that asks the backend AI gateway to generate creatures.
class GeminiService {
  final CreatureGenerationGateway _gateway;
  final Uuid _uuid;

  GeminiService({CreatureGenerationGateway? gateway, Uuid? uuid})
    : _gateway = gateway ?? FirebaseFunctionsCreatureGateway(),
      _uuid = uuid ?? const Uuid();

  Future<Creature> generateCreature({
    required List<String> labels,
    required String userId,
    required int userLevel,
    required int streakMultiplier,
    String? imageBase64,
    String? imageMimeType,
  }) async {
    final scannedObject = _scannedObjectFromLabels(labels);
    final scanImageUrl = _scanImageDataUrl(imageBase64, imageMimeType);

    try {
      final response = await _gateway.generateCreature(
        CreatureGenerationRequest(
          labels: labels,
          userLevel: userLevel,
          streakMultiplier: streakMultiplier,
          imageBase64: imageBase64,
          imageMimeType: imageMimeType,
        ),
      );
      final creatureData = _normalizeGeneratedCreatureData(response.data);
      final creatureMap = {
        ...creatureData,
        'id': _uuid.v4(),
        'userId': userId,
        'scannedObject': scannedObject,
        'scannedLabels': labels,
        'discoveredAt': DateTime.now().toIso8601String(),
        'evolutionShards': 0,
      };
      if (scanImageUrl != null) creatureMap['imageUrl'] = scanImageUrl;
      return Creature.fromMap(creatureMap);
    } catch (error, stackTrace) {
      // Keep the reveal flow usable, but leave evidence for backend diagnosis.
      debugPrint('Creature generation failed, using fallback: $error');
      debugPrintStack(stackTrace: stackTrace);
      return _fallbackCreature(
        userId: userId,
        scannedObject: scannedObject,
        labels: labels,
        userLevel: userLevel,
        streakMultiplier: streakMultiplier,
        imageUrl: scanImageUrl,
      );
    }
  }

  String _scannedObjectFromLabels(List<String> labels) {
    if (labels.isEmpty) return 'Unknown Object';
    return labels.first.replaceFirst(RegExp(r'\s+\d+%$'), '').trim();
  }

  Creature _fallbackCreature({
    required String userId,
    required String scannedObject,
    required List<String> labels,
    required int userLevel,
    required int streakMultiplier,
    String? imageUrl,
  }) {
    final objectName = _friendlyObjectName(scannedObject);
    final seed = _seedFrom('$objectName|${labels.join('|')}|$userLevel');
    final type = _fallbackTypeFor(objectName, seed);
    final rarity = _fallbackRarity(userLevel, streakMultiplier, seed);
    final hp = _fallbackStat(44, rarity, seed);
    final attack = _fallbackStat(48, rarity, seed ~/ 3);
    final defense = _fallbackStat(46, rarity, seed ~/ 5);
    final speed = _fallbackStat(50, rarity, seed ~/ 7);

    return Creature(
      id: _uuid.v4(),
      userId: userId,
      name: _fallbackCreatureName(objectName, seed),
      type: type,
      rarity: rarity,
      hp: hp,
      attack: attack,
      defense: defense,
      speed: speed,
      imageUrl: imageUrl,
      abilities: [
        CreatureAbility(
          name: '${_abilityPrefix(type)} Pulse',
          description:
              'Channels the scanned $objectName into a quick field burst.',
          type: type,
        ),
        CreatureAbility(
          name: 'Object Echo',
          description:
              'Copies the shape and texture of the scan into a guard aura.',
          type: type,
        ),
      ],
      lore:
          'Local synthesis shaped this creature from the scanned $objectName while Gemma was temporarily unavailable.',
      scannedObject: scannedObject,
      scannedLabels: labels,
      discoveredAt: DateTime.now(),
    );
  }

  String? _scanImageDataUrl(String? imageBase64, String? imageMimeType) {
    if (imageBase64 == null || imageBase64.isEmpty) return null;
    final mimeType = imageMimeType ?? 'image/jpeg';
    return 'data:$mimeType;base64,$imageBase64';
  }

  Map<String, dynamic> _normalizeGeneratedCreatureData(
    Map<String, dynamic> data,
  ) {
    final type = data['type'] is String ? data['type'] as String : 'Nature';
    return {
      'name': data['name'] is String ? data['name'] : 'Fieldborn Sprite',
      'type': type,
      'rarity': data['rarity'] is String ? data['rarity'] : 'Common',
      'hp': data['hp'],
      'attack': data['attack'],
      'defense': data['defense'],
      'speed': data['speed'],
      'abilities': _normalizeAbilities(data['abilities'], type),
      'lore': data['lore'] is String ? data['lore'] : '',
      if (data['imageUrl'] is String) 'imageUrl': data['imageUrl'],
    };
  }

  List<Map<String, dynamic>> _normalizeAbilities(Object? value, String type) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((ability) {
          final normalized = Map<String, dynamic>.from(ability);
          return {
            'name': normalized['name'] is String
                ? normalized['name']
                : 'Field Pulse',
            'description': normalized['description'] is String
                ? normalized['description']
                : 'A scan-born technique.',
            'type': normalized['type'] is String ? normalized['type'] : type,
          };
        })
        .toList(growable: false);
  }

  String _friendlyObjectName(String scannedObject) {
    final cleaned = scannedObject.trim().toLowerCase();
    if (cleaned.isEmpty ||
        cleaned == 'unknown object' ||
        cleaned == 'unlabeled object') {
      return 'scanned relic';
    }
    return cleaned;
  }

  String _fallbackCreatureName(String objectName, int seed) {
    final suffixes = [
      'Sprite',
      'Warden',
      'Imp',
      'Oracle',
      'Runner',
      'Sentinel',
    ];
    final name = objectName
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
    return '${name.isEmpty ? 'Scanned Relic' : name} ${suffixes[seed % suffixes.length]}';
  }

  String _fallbackTypeFor(String objectName, int seed) {
    if (objectName.contains('phone') ||
        objectName.contains('remote') ||
        objectName.contains('electronic')) {
      return 'Electric';
    }
    if (objectName.contains('book') ||
        objectName.contains('paper') ||
        objectName.contains('text') ||
        objectName.contains('logo')) {
      return 'Light';
    }
    if (objectName.contains('plant') || objectName.contains('leaf')) {
      return 'Nature';
    }
    if (objectName.contains('cup') ||
        objectName.contains('mug') ||
        objectName.contains('bottle')) {
      return 'Water';
    }
    const types = ['Shadow', 'Light', 'Earth', 'Electric', 'Air', 'Nature'];
    return types[seed % types.length];
  }

  String _fallbackRarity(int userLevel, int streakMultiplier, int seed) {
    final score = userLevel + (streakMultiplier * 2) + (seed % 10);
    if (score >= 24) return 'Rare';
    if (score >= 12) return 'Uncommon';
    return 'Common';
  }

  int _fallbackStat(int base, String rarity, int seed) {
    final bonus = switch (rarity.toLowerCase()) {
      'rare' => 18,
      'uncommon' => 10,
      _ => 0,
    };
    return (base + bonus + (seed % 18)).clamp(30, 86).toInt();
  }

  int _seedFrom(String value) {
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  String _abilityPrefix(String type) {
    return switch (type.toLowerCase()) {
      'fire' => 'Ember',
      'water' => 'Tide',
      'earth' => 'Stone',
      'air' => 'Gale',
      'electric' => 'Spark',
      'nature' => 'Verdant',
      'light' => 'Glimmer',
      'shadow' => 'Umbral',
      _ => 'Field',
    };
  }
}

final creatureGenerationGatewayProvider = Provider<CreatureGenerationGateway>((
  ref,
) {
  final openRouterApiKey = _openRouterApiKey();
  if (openRouterApiKey.isNotEmpty) {
    return OpenRouterCreatureGateway(apiKey: openRouterApiKey);
  }
  return FirebaseFunctionsCreatureGateway();
});

String _openRouterApiKey() {
  const dartDefineKey = String.fromEnvironment('OPENROUTER_API_KEY');
  if (dartDefineKey.isNotEmpty) return dartDefineKey;
  if (!dotenv.isInitialized) return '';
  return dotenv.maybeGet('OPENROUTER_API_KEY', fallback: '') ?? '';
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(gateway: ref.watch(creatureGenerationGatewayProvider));
});

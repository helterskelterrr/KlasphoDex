import 'dart:convert';
import 'dart:io';

import 'package:creature_lens/models/creature.dart';
import 'package:creature_lens/providers/creature_provider.dart';
import 'package:creature_lens/services/creature_storage.dart';
import 'package:creature_lens/services/gemini_service.dart';
import 'package:creature_lens/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory tempDir;
  late Box<Map> box;
  late Box<Map> syncBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('creature_lens_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Map>(CreatureStorage.boxName);
    syncBox = await Hive.openBox<Map>(SyncService.queueBoxName);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test(
    'GeminiService sends creature generation through backend gateway',
    () async {
      late CreatureGenerationRequest capturedRequest;
      final service = GeminiService(
        gateway: _FakeCreatureGateway((request) async {
          capturedRequest = request;
          return const CreatureGenerationResponse({
            'name': 'Mugmoss Sprite',
            'type': 'Nature',
            'rarity': 'Rare',
            'hp': 70,
            'attack': 60,
            'defense': 64,
            'speed': 82,
            'abilities': [
              {
                'name': 'Leaf Glimmer',
                'description': 'Flashes with fresh green light.',
                'type': 'Nature',
              },
            ],
            'lore': 'A tiny guardian awakened by a scanner flash.',
          });
        }),
      );

      final creature = await service.generateCreature(
        labels: const ['ceramic mug 94%', 'plant leaf 71%'],
        userId: 'user-1',
        userLevel: 8,
        streakMultiplier: 2,
      );

      expect(capturedRequest.labels, const [
        'ceramic mug 94%',
        'plant leaf 71%',
      ]);
      expect(capturedRequest.userLevel, 8);
      expect(capturedRequest.streakMultiplier, 2);
      expect(capturedRequest.imageBase64, isNull);
      expect(creature.name, 'Mugmoss Sprite');
      expect(creature.userId, 'user-1');
      expect(creature.scannedObject, 'ceramic mug');
      expect(creature.scannedLabels, const [
        'ceramic mug 94%',
        'plant leaf 71%',
      ]);
    },
  );

  test('GeminiService falls back when the backend gateway fails', () async {
    final service = GeminiService(
      gateway: _FakeCreatureGateway((request) async {
        throw Exception('backend unavailable');
      }),
    );

    final creature = await service.generateCreature(
      labels: const ['ceramic mug 94%', 'plant leaf 71%'],
      userId: 'user-1',
      userLevel: 8,
      streakMultiplier: 2,
    );

    expect(creature, isA<Creature>());
    expect(creature.name, isNot('Mystery Creature'));
    expect(creature.name.toLowerCase(), contains('ceramic'));
    expect(creature.userId, 'user-1');
    expect(creature.scannedObject, 'ceramic mug');
    expect(creature.scannedLabels, const ['ceramic mug 94%', 'plant leaf 71%']);
  });

  test('GeminiService accepts string stats from generation response', () async {
    final service = GeminiService(
      gateway: _FakeCreatureGateway((request) async {
        return const CreatureGenerationResponse({
          'name': 'Cupflare Warden',
          'type': 'Fire',
          'rarity': 'epic',
          'hp': '72',
          'attack': '88',
          'defense': '63',
          'speed': '91',
          'abilities': [
            {
              'name': 'Steam Guard',
              'description': 'Raises a warm shield from the scanned mug.',
              'type': 'Fire',
            },
          ],
          'lore': 'A kiln-born sentinel with a porcelain heart.',
        });
      }),
    );

    final creature = await service.generateCreature(
      labels: const ['ceramic mug 94%'],
      userId: 'user-1',
      userLevel: 8,
      streakMultiplier: 2,
    );

    expect(creature.name, 'Cupflare Warden');
    expect(creature.rarity, 'Epic');
    expect(creature.hp, 72);
    expect(creature.attack, 88);
    expect(creature.defense, 63);
    expect(creature.speed, 91);
    expect(creature.abilities.single.name, 'Steam Guard');
  });

  test('GeminiService can send final scan image evidence', () async {
    late CreatureGenerationRequest capturedRequest;
    final service = GeminiService(
      gateway: _FakeCreatureGateway((request) async {
        capturedRequest = request;
        return const CreatureGenerationResponse({
          'name': 'Lenscup Oracle',
          'type': 'Light',
          'rarity': 'Rare',
          'hp': 72,
          'attack': 58,
          'defense': 61,
          'speed': 80,
          'abilities': [
            {
              'name': 'Glimmer Read',
              'description': 'Reads the object silhouette from the scan.',
              'type': 'Light',
            },
          ],
          'lore': 'A creature awakened from the final camera frame.',
        });
      }),
    );

    final creature = await service.generateCreature(
      labels: const ['unknown object 50%'],
      userId: 'user-1',
      userLevel: 8,
      streakMultiplier: 2,
      imageBase64: 'ZmFrZS1pbWFnZQ==',
      imageMimeType: 'image/jpeg',
    );

    expect(capturedRequest.imageBase64, 'ZmFrZS1pbWFnZQ==');
    expect(capturedRequest.imageMimeType, 'image/jpeg');
    expect(
      capturedRequest.toMap(),
      containsPair('imageBase64', 'ZmFrZS1pbWFnZQ=='),
    );
    expect(creature.imageUrl, 'data:image/jpeg;base64,ZmFrZS1pbWFnZQ==');
    expect(creature.name, 'Lenscup Oracle');
  });

  test(
    'OpenRouterCreatureGateway calls only the Gemma model directly',
    () async {
      final gateway = OpenRouterCreatureGateway(
        apiKey: 'test-key',
        client: MockClient((request) async {
          expect(
            request.url.toString(),
            'https://openrouter.ai/api/v1/chat/completions',
          );
          expect(request.headers['Authorization'], 'Bearer test-key');

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['model'], 'google/gemma-4-31b-it:free');
          expect(body['messages'], isA<List<dynamic>>());
          expect(body['response_format'], const {'type': 'json_object'});

          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'name': 'Gemma Lensling',
                      'type': 'Light',
                      'rarity': 'Rare',
                      'hp': 70,
                      'attack': 62,
                      'defense': 58,
                      'speed': 84,
                      'abilities': [
                        {
                          'name': 'Direct Spark',
                          'description': 'Channels the scan straight to Gemma.',
                          'type': 'Light',
                        },
                      ],
                      'lore': 'A field creature generated without Functions.',
                    }),
                  },
                },
              ],
            }),
            200,
          );
        }),
      );

      final response = await gateway.generateCreature(
        const CreatureGenerationRequest(
          labels: ['ceramic mug 94%'],
          userLevel: 8,
          streakMultiplier: 2,
        ),
      );

      expect(response.data['name'], 'Gemma Lensling');
      expect(response.data['type'], 'Light');
    },
  );

  test(
    'OpenRouterCreatureGateway falls back to Gemma 26B A4B when primary Gemma is rate-limited',
    () async {
      final models = <String>[];
      final gateway = OpenRouterCreatureGateway(
        apiKey: 'test-key',
        client: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final model = body['model'] as String;
          models.add(model);

          if (model == 'google/gemma-4-31b-it:free') {
            return http.Response(
              jsonEncode({
                'error': {'message': 'primary model rate-limited'},
              }),
              429,
            );
          }

          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'name': 'A4B Backup Sprite',
                      'type': 'Electric',
                      'rarity': 'Uncommon',
                      'hp': 64,
                      'attack': 70,
                      'defense': 58,
                      'speed': 76,
                      'abilities': [
                        {
                          'name': 'Backup Spark',
                          'description':
                              'Triggers when the primary Gemma path is busy.',
                          'type': 'Electric',
                        },
                      ],
                      'lore': 'A fallback creature generated by Gemma 26B A4B.',
                    }),
                  },
                },
              ],
            }),
            200,
          );
        }),
      );

      final response = await gateway.generateCreature(
        const CreatureGenerationRequest(
          labels: ['speaker case 73%'],
          userLevel: 8,
          streakMultiplier: 2,
        ),
      );

      expect(models, const [
        'google/gemma-4-31b-it:free',
        'google/gemma-4-26b-a4b-it:free',
      ]);
      expect(response.data['name'], 'A4B Backup Sprite');
    },
  );

  test(
    'OpenRouterCreatureGateway falls back to Nemotron Omni when both Gemmas are rate-limited',
    () async {
      final models = <String>[];
      final gateway = OpenRouterCreatureGateway(
        apiKey: 'test-key',
        client: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final model = body['model'] as String;
          models.add(model);

          if (model.startsWith('google/gemma-4-')) {
            return http.Response(
              jsonEncode({
                'error': {'message': 'gemma model rate-limited'},
              }),
              429,
            );
          }

          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'name': 'Nemotron Fieldseer',
                      'type': 'Light',
                      'rarity': 'Rare',
                      'hp': 72,
                      'attack': 68,
                      'defense': 61,
                      'speed': 82,
                      'abilities': [
                        {
                          'name': 'Omni Read',
                          'description':
                              'Reads the image after both Gemma paths are busy.',
                          'type': 'Light',
                        },
                      ],
                      'lore':
                          'A perception sprite generated by the Nemotron plan C.',
                    }),
                  },
                },
              ],
            }),
            200,
          );
        }),
      );

      final response = await gateway.generateCreature(
        const CreatureGenerationRequest(
          labels: ['unknown object 50%'],
          userLevel: 8,
          streakMultiplier: 2,
          imageBase64: 'ZmFrZS1pbWFnZQ==',
          imageMimeType: 'image/jpeg',
        ),
      );

      expect(models, const [
        'google/gemma-4-31b-it:free',
        'google/gemma-4-26b-a4b-it:free',
        'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
      ]);
      expect(response.data['name'], 'Nemotron Fieldseer');
    },
  );

  test('GeminiService falls back on malformed generation response', () async {
    final service = GeminiService(
      gateway: _FakeCreatureGateway((request) async {
        return const CreatureGenerationResponse({
          'name': 'Broken Sprite',
          'abilities': ['not an ability map'],
        });
      }),
    );

    final creature = await service.generateCreature(
      labels: const ['ceramic mug 94%'],
      userId: 'user-1',
      userLevel: 8,
      streakMultiplier: 2,
    );

    expect(creature.name, isNot('Mystery Creature'));
    expect(creature.scannedObject, 'ceramic mug');
    expect(creature.scannedLabels, const ['ceramic mug 94%']);
  });

  test('Flutter source does not hardcode the OpenRouter secret value', () {
    final sourceFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    final combinedSource = sourceFiles
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(combinedSource, isNot(contains(['sk', 'or', 'v1'].join('-'))));
  });

  test('pubspec bundles dotenv only for the direct demo path', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('flutter_dotenv'));
    expect(pubspec, contains('    - .env'));
  });

  test('README documents direct demo key setup', () {
    final readme = File('README.md').readAsStringSync();

    expect(readme, contains('OPENROUTER_API_KEY'));
    expect(readme, contains('--dart-define=OPENROUTER_API_KEY'));
  });

  test('scan screen uses photo capture instead of YOLO detection', () {
    final source = File('lib/screens/scan/scan_screen.dart').readAsStringSync();

    expect(source, isNot(contains('ultralytics_yolo')));
    expect(source, isNot(contains('YOLOView')));
    expect(source, isNot(contains('YoloDetectionService')));
    expect(source, contains('ImageSource.camera'));
  });

  test(
    'CreatureCollectionNotifier persists add and remove operations',
    () async {
      final storage = CreatureStorage(box);
      final syncService = SyncService(syncBox);
      final container = ProviderContainer(
        overrides: [
          creatureStorageProvider.overrideWithValue(storage),
          syncServiceProvider.overrideWithValue(syncService),
        ],
      );
      addTearDown(container.dispose);

      final initial = container.read(allCreaturesProvider);
      expect(initial, isEmpty);

      final creature = _creature();

      await container.read(allCreaturesProvider.notifier).add(creature);
      expect(storage.loadAll().single.toMap(), creature.toMap());
      expect(syncService.loadPending(), hasLength(1));
      expect(
        syncService.loadPending().single.entityType,
        SyncEntityType.creature,
      );
      expect(syncService.loadPending().single.operation, SyncOperation.upsert);
      expect(
        syncService.loadPending().single.payload['name'],
        'Mugmoss Sprite',
      );

      await container.read(allCreaturesProvider.notifier).remove(creature.id);
      expect(storage.loadAll(), isEmpty);
      expect(syncService.loadPending().single.operation, SyncOperation.delete);
    },
  );

  test(
    'CreatureCollectionNotifier can add shards to a creature by id',
    () async {
      final storage = CreatureStorage(box);
      final syncService = SyncService(syncBox);
      final container = ProviderContainer(
        overrides: [
          creatureStorageProvider.overrideWithValue(storage),
          syncServiceProvider.overrideWithValue(syncService),
        ],
      );
      addTearDown(container.dispose);

      final creature = _creature(evolutionShards: 1);

      await container.read(allCreaturesProvider.notifier).add(creature);
      await container
          .read(allCreaturesProvider.notifier)
          .addShardsToCreature('scan-1', 3);

      expect(container.read(allCreaturesProvider).single.evolutionShards, 4);
      expect(storage.loadAll().single.evolutionShards, 4);
      expect(syncService.loadPending().single.payload['evolutionShards'], 4);
    },
  );
}

Creature _creature({int evolutionShards = 0}) {
  return Creature(
    id: 'scan-1',
    userId: 'guest',
    name: 'Mugmoss Sprite',
    type: 'Nature',
    rarity: 'Rare',
    hp: 70,
    attack: 60,
    defense: 64,
    speed: 82,
    abilities: const [
      CreatureAbility(
        name: 'Leaf Glimmer',
        description: 'Flashes with fresh green light.',
        type: 'Nature',
      ),
    ],
    lore: 'A tiny guardian awakened by a scanner flash.',
    scannedObject: 'ceramic mug',
    scannedLabels: const ['ceramic mug 94%'],
    discoveredAt: DateTime.utc(2026, 5, 7),
    evolutionShards: evolutionShards,
  );
}

class _FakeCreatureGateway implements CreatureGenerationGateway {
  const _FakeCreatureGateway(this._generate);

  final Future<CreatureGenerationResponse> Function(
    CreatureGenerationRequest request,
  )
  _generate;

  @override
  Future<CreatureGenerationResponse> generateCreature(
    CreatureGenerationRequest request,
  ) {
    return _generate(request);
  }
}

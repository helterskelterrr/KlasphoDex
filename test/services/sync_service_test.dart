import 'dart:io';

import 'package:creature_lens/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box<Map> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sync_service_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Map>(SyncService.queueBoxName);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test(
    'enqueues upsert and delete records with stable serialization',
    () async {
      final service = SyncService(box);
      final queuedAt = DateTime.utc(2026, 5, 12, 4, 30);

      await service.enqueueUpsert(
        entityType: SyncEntityType.creature,
        entityId: 'creature-1',
        payload: const {'name': 'Mugmoss Sprite', 'power': 64},
        queuedAt: queuedAt,
      );

      expect(service.loadPending().single.toMap(), {
        'id': 'creature:upsert:creature-1',
        'entityType': 'creature',
        'operation': 'upsert',
        'entityId': 'creature-1',
        'payload': {'name': 'Mugmoss Sprite', 'power': 64},
        'queuedAt': queuedAt.toIso8601String(),
        'attemptCount': 0,
        'lastError': null,
      });

      await service.enqueueDelete(
        entityType: SyncEntityType.creature,
        entityId: 'creature-1',
        queuedAt: queuedAt,
      );

      expect(service.loadPending().single.toMap(), {
        'id': 'creature:delete:creature-1',
        'entityType': 'creature',
        'operation': 'delete',
        'entityId': 'creature-1',
        'payload': <String, dynamic>{},
        'queuedAt': queuedAt.toIso8601String(),
        'attemptCount': 0,
        'lastError': null,
      });
    },
  );

  test(
    'preserves pending queue records when no remote gateway exists',
    () async {
      final service = SyncService(box);

      await service.enqueueUpsert(
        entityType: SyncEntityType.battleDeck,
        entityId: 'active-deck',
        payload: const {
          'id': 'active-deck',
          'name': 'Field Deck',
          'creatureIds': ['c1', 'c2'],
        },
      );

      final summary = await service.syncPending();

      expect(summary.attempted, 0);
      expect(summary.succeeded, 0);
      expect(summary.failed, 0);
      expect(summary.skipped, 1);
      expect(service.loadPending(), hasLength(1));
    },
  );

  test('removes records only after a successful remote push', () async {
    final gateway = _RecordingGateway(
      failIds: const {'trialResult:upsert:trial-2'},
    );
    final service = SyncService(box, remoteGateway: gateway);

    await service.enqueueUpsert(
      entityType: SyncEntityType.trialResult,
      entityId: 'trial-1',
      payload: const {'id': 'trial-1', 'victory': true},
    );
    await service.enqueueUpsert(
      entityType: SyncEntityType.trialResult,
      entityId: 'trial-2',
      payload: const {'id': 'trial-2', 'victory': false},
    );

    final summary = await service.syncPending();

    expect(summary.attempted, 2);
    expect(summary.succeeded, 1);
    expect(summary.failed, 1);
    expect(summary.skipped, 0);
    expect(gateway.pushed.map((item) => item.id), [
      'trialResult:upsert:trial-1',
      'trialResult:upsert:trial-2',
    ]);

    final pending = service.loadPending();
    expect(pending, hasLength(1));
    expect(pending.single.id, 'trialResult:upsert:trial-2');
    expect(pending.single.attemptCount, 1);
    expect(pending.single.lastError, contains('remote unavailable'));
  });

  test('loads a remote snapshot without mutating the local queue', () async {
    final gateway = _RecordingGateway(
      snapshot: const RemoteSyncSnapshot(
        creatures: {
          'creature-1': {'id': 'creature-1', 'name': 'Mugmoss Sprite'},
        },
        battleDecks: {
          'active-deck': {
            'id': 'active-deck',
            'name': 'Field Deck',
            'creatureIds': ['creature-1'],
          },
        },
        trialResults: {
          'trial-1': {'id': 'trial-1', 'victory': true},
        },
      ),
    );
    final service = SyncService(box, remoteGateway: gateway);

    await service.enqueueUpsert(
      entityType: SyncEntityType.creature,
      entityId: 'local-pending',
      payload: const {'id': 'local-pending', 'name': 'Local Pending'},
    );

    final snapshot = await service.pullSnapshot();

    expect(gateway.pullCount, 1);
    expect(snapshot.totalRecords, 3);
    expect(snapshot.creatures['creature-1']!['name'], 'Mugmoss Sprite');
    expect(snapshot.battleDecks['active-deck']!['creatureIds'], ['creature-1']);
    expect(snapshot.trialResults['trial-1']!['victory'], isTrue);
    expect(service.loadPending(), hasLength(1));
  });

  test('can schedule a background sync after enqueue', () async {
    final gateway = _RecordingGateway();
    final service = SyncService(
      box,
      remoteGateway: gateway,
      syncAfterEnqueue: true,
    );

    await service.enqueueUpsert(
      entityType: SyncEntityType.creature,
      entityId: 'creature-1',
      payload: const {'id': 'creature-1', 'name': 'Mugmoss Sprite'},
    );
    await _pumpUntil(() => gateway.pushed.length == 1);

    expect(gateway.pushed.single.id, 'creature:upsert:creature-1');
    expect(service.loadPending(), isEmpty);
  });

  test('sync gateway source does not sign in users implicitly', () {
    final source = File('lib/services/sync_service.dart').readAsStringSync();

    expect(source, isNot(contains('signInAnonymously')));
    expect(source, contains('No Firebase user is signed in.'));
  });
}

class _RecordingGateway implements RemoteSyncGateway {
  _RecordingGateway({
    this.failIds = const {},
    this.snapshot = const RemoteSyncSnapshot(),
  });

  final Set<String> failIds;
  final RemoteSyncSnapshot snapshot;
  final List<SyncQueueItem> pushed = [];
  int pullCount = 0;

  @override
  Future<void> push(SyncQueueItem item) async {
    pushed.add(item);
    if (failIds.contains(item.id)) {
      throw Exception('remote unavailable');
    }
  }

  @override
  Future<RemoteSyncSnapshot> pullSnapshot() async {
    pullCount++;
    return snapshot;
  }
}

Future<void> _pumpUntil(bool Function() condition) async {
  for (var i = 0; i < 20; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

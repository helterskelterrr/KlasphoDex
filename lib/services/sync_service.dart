import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

enum SyncEntityType { creature, battleDeck, trialResult }

enum SyncOperation { upsert, delete }

abstract class RemoteSyncGateway {
  Future<void> push(SyncQueueItem item);

  Future<RemoteSyncSnapshot> pullSnapshot();
}

class RemoteSyncSnapshot {
  const RemoteSyncSnapshot({
    this.creatures = const {},
    this.battleDecks = const {},
    this.trialResults = const {},
  });

  final Map<String, Map<String, dynamic>> creatures;
  final Map<String, Map<String, dynamic>> battleDecks;
  final Map<String, Map<String, dynamic>> trialResults;

  int get totalRecords =>
      creatures.length + battleDecks.length + trialResults.length;
}

class SyncQueueItem {
  SyncQueueItem({
    String? id,
    required this.entityType,
    required this.operation,
    required this.entityId,
    Map<String, dynamic>? payload,
    DateTime? queuedAt,
    this.attemptCount = 0,
    this.lastError,
  }) : payload = Map<String, dynamic>.unmodifiable(payload ?? const {}),
       queuedAt = queuedAt ?? DateTime.now(),
       id = id ?? _queueId(entityType, operation, entityId);

  final String id;
  final SyncEntityType entityType;
  final SyncOperation operation;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime queuedAt;
  final int attemptCount;
  final String? lastError;

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as String?,
      entityType: _entityTypeFromWireName(map['entityType'] as String?),
      operation: _operationFromWireName(map['operation'] as String?),
      entityId: map['entityId'] as String? ?? '',
      payload: _mapFromDynamic(map['payload']),
      queuedAt:
          DateTime.tryParse(map['queuedAt'] as String? ?? '') ?? DateTime.now(),
      attemptCount: map['attemptCount'] as int? ?? 0,
      lastError: map['lastError'] as String?,
    );
  }

  SyncQueueItem copyWith({
    int? attemptCount,
    String? lastError,
    DateTime? queuedAt,
  }) {
    return SyncQueueItem(
      id: id,
      entityType: entityType,
      operation: operation,
      entityId: entityId,
      payload: payload,
      queuedAt: queuedAt ?? this.queuedAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityType': entityType.wireName,
      'operation': operation.wireName,
      'entityId': entityId,
      'payload': Map<String, dynamic>.from(payload),
      'queuedAt': queuedAt.toIso8601String(),
      'attemptCount': attemptCount,
      'lastError': lastError,
    };
  }

  static String _queueId(
    SyncEntityType entityType,
    SyncOperation operation,
    String entityId,
  ) {
    return '${entityType.wireName}:${operation.wireName}:$entityId';
  }
}

class SyncRunSummary {
  const SyncRunSummary({
    required this.attempted,
    required this.succeeded,
    required this.failed,
    required this.skipped,
  });

  final int attempted;
  final int succeeded;
  final int failed;
  final int skipped;
}

class SyncService {
  static const queueBoxName = 'sync_queue';

  const SyncService(
    this._box, {
    RemoteSyncGateway? remoteGateway,
    bool syncAfterEnqueue = false,
  }) : _remoteGateway = remoteGateway,
       _syncAfterEnqueue = syncAfterEnqueue;

  final Box<Map> _box;
  final RemoteSyncGateway? _remoteGateway;
  final bool _syncAfterEnqueue;

  List<SyncQueueItem> loadPending() {
    return _box.values
        .map((value) => SyncQueueItem.fromMap(Map<String, dynamic>.from(value)))
        .toList()
      ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
  }

  Future<void> enqueueUpsert({
    required SyncEntityType entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    DateTime? queuedAt,
  }) async {
    await _removePending(
      entityType: entityType,
      operation: SyncOperation.delete,
      entityId: entityId,
    );
    final item = SyncQueueItem(
      entityType: entityType,
      operation: SyncOperation.upsert,
      entityId: entityId,
      payload: payload,
      queuedAt: queuedAt,
    );
    await _box.put(item.id, item.toMap());
    _scheduleBackgroundSync();
  }

  Future<void> enqueueDelete({
    required SyncEntityType entityType,
    required String entityId,
    DateTime? queuedAt,
  }) async {
    await _removePending(
      entityType: entityType,
      operation: SyncOperation.upsert,
      entityId: entityId,
    );
    final item = SyncQueueItem(
      entityType: entityType,
      operation: SyncOperation.delete,
      entityId: entityId,
      queuedAt: queuedAt,
    );
    await _box.put(item.id, item.toMap());
    _scheduleBackgroundSync();
  }

  Future<SyncRunSummary> syncPending() async {
    final gateway = _remoteGateway;
    final pending = loadPending();
    if (gateway == null) {
      return SyncRunSummary(
        attempted: 0,
        succeeded: 0,
        failed: 0,
        skipped: pending.length,
      );
    }

    var succeeded = 0;
    var failed = 0;
    for (final item in pending) {
      try {
        await gateway.push(item);
        await _box.delete(item.id);
        succeeded++;
      } catch (error) {
        failed++;
        final failedItem = item.copyWith(
          attemptCount: item.attemptCount + 1,
          lastError: error.toString(),
        );
        await _box.put(item.id, failedItem.toMap());
      }
    }

    return SyncRunSummary(
      attempted: pending.length,
      succeeded: succeeded,
      failed: failed,
      skipped: 0,
    );
  }

  Future<RemoteSyncSnapshot> pullSnapshot() async {
    final gateway = _remoteGateway;
    if (gateway == null) return const RemoteSyncSnapshot();
    return gateway.pullSnapshot();
  }

  Future<void> _removePending({
    required SyncEntityType entityType,
    required SyncOperation operation,
    required String entityId,
  }) {
    return _box.delete(
      '${entityType.wireName}:${operation.wireName}:$entityId',
    );
  }

  void _scheduleBackgroundSync() {
    if (!_syncAfterEnqueue || _remoteGateway == null) return;
    unawaited(syncPending());
  }
}

class FirebaseFirestoreSyncGateway implements RemoteSyncGateway {
  FirebaseFirestoreSyncGateway({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<void> push(SyncQueueItem item) async {
    final uid = await _requireUid();
    final document = _collection(uid, item.entityType).doc(item.entityId);

    switch (item.operation) {
      case SyncOperation.upsert:
        await document.set({
          ...item.payload,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      case SyncOperation.delete:
        await document.delete();
    }
  }

  @override
  Future<RemoteSyncSnapshot> pullSnapshot() async {
    final uid = await _requireUid();
    final snapshots = await Future.wait([
      _collection(uid, SyncEntityType.creature).get(),
      _collection(uid, SyncEntityType.battleDeck).get(),
      _collection(uid, SyncEntityType.trialResult).get(),
    ]);

    return RemoteSyncSnapshot(
      creatures: _documentsToMap(snapshots[0]),
      battleDecks: _documentsToMap(snapshots[1]),
      trialResults: _documentsToMap(snapshots[2]),
    );
  }

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    SyncEntityType entityType,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection(entityType.collectionName);
  }

  Future<String> _requireUid() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) return currentUser.uid;

    throw StateError('No Firebase user is signed in.');
  }

  Map<String, Map<String, dynamic>> _documentsToMap(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return {
      for (final document in snapshot.docs)
        document.id: Map<String, dynamic>.from(document.data()),
    };
  }
}

final remoteSyncGatewayProvider = Provider<RemoteSyncGateway>((ref) {
  return FirebaseFirestoreSyncGateway();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    Hive.box<Map>(SyncService.queueBoxName),
    remoteGateway: ref.watch(remoteSyncGatewayProvider),
    syncAfterEnqueue: true,
  );
});

extension SyncEntityTypeWireName on SyncEntityType {
  String get wireName {
    switch (this) {
      case SyncEntityType.creature:
        return 'creature';
      case SyncEntityType.battleDeck:
        return 'battleDeck';
      case SyncEntityType.trialResult:
        return 'trialResult';
    }
  }
}

extension SyncEntityTypeCollectionName on SyncEntityType {
  String get collectionName {
    switch (this) {
      case SyncEntityType.creature:
        return 'creatures';
      case SyncEntityType.battleDeck:
        return 'battleDecks';
      case SyncEntityType.trialResult:
        return 'trialResults';
    }
  }
}

extension SyncOperationWireName on SyncOperation {
  String get wireName {
    switch (this) {
      case SyncOperation.upsert:
        return 'upsert';
      case SyncOperation.delete:
        return 'delete';
    }
  }
}

SyncEntityType _entityTypeFromWireName(String? value) {
  switch (value) {
    case 'battleDeck':
      return SyncEntityType.battleDeck;
    case 'trialResult':
      return SyncEntityType.trialResult;
    case 'creature':
    default:
      return SyncEntityType.creature;
  }
}

SyncOperation _operationFromWireName(String? value) {
  switch (value) {
    case 'delete':
      return SyncOperation.delete;
    case 'upsert':
    default:
      return SyncOperation.upsert;
  }
}

Map<String, dynamic> _mapFromDynamic(Object? value) {
  if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
  if (value is Map) return value.map((key, value) => MapEntry('$key', value));
  return <String, dynamic>{};
}

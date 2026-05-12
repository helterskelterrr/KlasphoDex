import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/trial_result.dart';

class TrialResultStorage {
  static const boxName = 'trial_results';

  final Box<Map> _box;

  const TrialResultStorage(this._box);

  List<TrialResult> loadAll() {
    return _box.values
        .map((value) => TrialResult.fromMap(Map<String, dynamic>.from(value)))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Future<void> save(TrialResult result) {
    return _box.put(result.id, result.toMap());
  }
}

final trialResultStorageProvider = Provider<TrialResultStorage>((ref) {
  return TrialResultStorage(Hive.box<Map>(TrialResultStorage.boxName));
});

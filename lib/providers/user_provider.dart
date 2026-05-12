import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> loadOrCreateUser(String uid);

  Future<void> saveUser(UserModel user);
}

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<UserModel> loadOrCreateUser(String uid) async {
    final document = _firestore.collection('users').doc(uid);
    final snapshot = await document.get();
    if (snapshot.exists && snapshot.data() != null) {
      return UserModel.fromMap({...snapshot.data()!, 'uid': uid});
    }

    final user = UserModel(
      uid: uid,
      displayName: 'Field Researcher',
      email: '',
      level: 1,
      xp: 0,
      totalCreatures: 0,
      currentStreak: 0,
      longestStreak: 0,
      achievements: const [],
      createdAt: DateTime.now(),
    );
    await document.set(user.toMap(), SetOptions(merge: true));
    return user;
  }

  @override
  Future<void> saveUser(UserModel user) {
    return _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirestoreUserRepository();
});

final initialUserProvider = Provider<UserModel>((ref) {
  return UserModel(
    uid: 'local-anonymous',
    displayName: 'Field Researcher',
    email: '',
    createdAt: DateTime.now(),
  );
});

class UserNotifier extends Notifier<UserModel> {
  @override
  UserModel build() {
    return ref.watch(initialUserProvider);
  }

  void hydrateAuthenticatedUser(UserModel user) {
    state = user;
  }

  Future<void> update(UserModel user) async {
    state = user;
    await ref.read(userRepositoryProvider).saveUser(user);
  }

  Future<void> addXp(int amount) async {
    var newXp = state.xp + amount;
    var newLevel = state.level;
    var nextLevelXp = state.xpToNextLevel;
    while (newXp >= nextLevelXp) {
      newXp -= nextLevelXp;
      newLevel++;
      nextLevelXp = newLevel * 100 + (newLevel ~/ 5) * 50;
    }
    await update(state.copyWith(xp: newXp, level: newLevel));
  }

  Future<void> setTotalCreatures(int totalCreatures) {
    return update(state.copyWith(totalCreatures: totalCreatures));
  }
}

final userProvider = NotifierProvider<UserNotifier, UserModel>(
  UserNotifier.new,
);

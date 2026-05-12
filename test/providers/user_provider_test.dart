import 'package:creature_lens/models/user_model.dart';
import 'package:creature_lens/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserNotifier starts from authenticated bootstrap user', () {
    final user = _user(uid: 'auth-user-1', xp: 20);
    final container = ProviderContainer(
      overrides: [initialUserProvider.overrideWithValue(user)],
    );
    addTearDown(container.dispose);

    expect(container.read(userProvider).uid, 'auth-user-1');
    expect(container.read(userProvider).xp, 20);
  });

  test('UserNotifier persists XP changes through the repository', () async {
    final repository = _RecordingUserRepository();
    final container = ProviderContainer(
      overrides: [
        initialUserProvider.overrideWithValue(
          _user(uid: 'auth-user-1', xp: 90),
        ),
        userRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userProvider.notifier).addXp(20);

    expect(container.read(userProvider).level, 2);
    expect(container.read(userProvider).xp, 10);
    expect(repository.saved.single.uid, 'auth-user-1');
    expect(repository.saved.single.level, 2);
    expect(repository.saved.single.xp, 10);
  });

  test(
    'UserNotifier persists creature count changes through the repository',
    () async {
      final repository = _RecordingUserRepository();
      final container = ProviderContainer(
        overrides: [
          initialUserProvider.overrideWithValue(
            _user(uid: 'auth-user-1', totalCreatures: 4),
          ),
          userRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userProvider.notifier).setTotalCreatures(5);

      expect(container.read(userProvider).totalCreatures, 5);
      expect(repository.saved.single.totalCreatures, 5);
    },
  );

  test('UserNotifier hydrates authenticated user without saving', () {
    final repository = _RecordingUserRepository();
    final container = ProviderContainer(
      overrides: [
        initialUserProvider.overrideWithValue(_user(uid: 'local-anonymous')),
        userRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(userProvider.notifier)
        .hydrateAuthenticatedUser(_user(uid: 'auth-user-1', xp: 20));

    expect(container.read(userProvider).uid, 'auth-user-1');
    expect(container.read(userProvider).xp, 20);
    expect(repository.saved, isEmpty);
  });
}

UserModel _user({
  required String uid,
  int xp = 0,
  int level = 1,
  int totalCreatures = 0,
}) {
  return UserModel(
    uid: uid,
    displayName: 'Field Researcher',
    email: '',
    level: level,
    xp: xp,
    totalCreatures: totalCreatures,
    createdAt: DateTime.utc(2026, 5, 12),
  );
}

class _RecordingUserRepository implements UserRepository {
  final saved = <UserModel>[];

  @override
  Future<UserModel> loadOrCreateUser(String uid) async {
    return _user(uid: uid);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    saved.add(user);
  }
}

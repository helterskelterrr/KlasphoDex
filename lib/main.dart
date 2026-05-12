import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'services/auth_service.dart';
import 'services/creature_storage.dart';
import 'services/deck_storage.dart';
import 'services/sync_service.dart';
import 'services/trial_result_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(isOptional: true);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive for local caching
  await Hive.initFlutter();
  await Hive.openBox<Map>(CreatureStorage.boxName);
  await Hive.openBox<Map>(DeckStorage.boxName);
  await Hive.openBox<Map>(TrialResultStorage.boxName);
  await Hive.openBox<Map>(SyncService.queueBoxName);

  runApp(
    const ProviderScope(
      child: _AuthenticatedUserBootstrap(child: CreatureLensApp()),
    ),
  );
}

class _AuthenticatedUserBootstrap extends ConsumerStatefulWidget {
  const _AuthenticatedUserBootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_AuthenticatedUserBootstrap> createState() =>
      _AuthenticatedUserBootstrapState();
}

class _AuthenticatedUserBootstrapState
    extends ConsumerState<_AuthenticatedUserBootstrap> {
  @override
  void initState() {
    super.initState();
    unawaited(_bootstrapUser());
  }

  Future<void> _bootstrapUser() async {
    try {
      final firebaseUser = await AuthService().ensureAnonymousUser().timeout(
        const Duration(seconds: 12),
      );
      final initialUser = await FirestoreUserRepository()
          .loadOrCreateUser(firebaseUser.uid)
          .timeout(const Duration(seconds: 12));
      if (!mounted) return;
      ref.read(userProvider.notifier).hydrateAuthenticatedUser(initialUser);
    } catch (error, stackTrace) {
      debugPrint('User bootstrap skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

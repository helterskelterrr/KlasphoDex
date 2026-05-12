import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<User> ensureAnonymousUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) return currentUser;

    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError('Anonymous Firebase sign-in did not return a user.');
    }
    return user;
  }
}

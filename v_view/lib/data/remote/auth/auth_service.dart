import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/auth/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      // Firestore 읽기 실패(보안 규칙 등)해도 로그인 성공으로 처리
      try {
        final doc = await _users.doc(uid).get();
        if (doc.exists) return UserModel.fromFirestore(doc);
      } catch (_) {}
      return UserModel(
        uid: uid,
        email: email.trim(),
        name: cred.user?.displayName ?? '',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception(FirebaseService.handleFirebaseError(e));
    }
  }

  Future<UserModel> signUpWithEmail(String email, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.updateDisplayName(name.trim());
      final user = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        name: name.trim(),
        createdAt: DateTime.now(),
      );
      await _users.doc(user.uid).set(user.toMap());
      return user;
    } catch (e) {
      throw Exception(FirebaseService.handleFirebaseError(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception(FirebaseService.handleFirebaseError(e));
    }
  }
}

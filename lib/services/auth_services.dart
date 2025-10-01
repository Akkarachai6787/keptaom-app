import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpResult {
  final String? uid;
  final String? error;

  SignUpResult({this.uid, this.error});

  bool get isSuccess => uid != null;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'enableBudget': true,
        'types': {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return SignUpResult(uid: uid);
    } on FirebaseAuthException catch (e) {
      return SignUpResult(error: _mapFirebaseErrorToMessage(e));
    } catch (e) {
      return SignUpResult(
        error: 'An unknown error occurred. Please try again.',
      );
    }
  }

  String _mapFirebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use. Try logging in.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger one.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'invalid-credential':
        return 'Incorrect password.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseErrorToMessage(e);
    } catch (e) {
      return 'An unknown error occurred';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Current user
  User? get currentUser => _auth.currentUser;
}

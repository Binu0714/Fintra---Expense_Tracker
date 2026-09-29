import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // signup
  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create the user credential in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // 2. Set the display name in Firebase Auth
        await user.updateDisplayName(name.trim());

        // 3. Save user profile document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Login
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // get user data
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // update user profile
  Future<void> updateUserProfile({
    required String name,
    required String email,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found.');

      final formattedName = name.trim();
      final formattedEmail = email.trim().toLowerCase();

      if (user.displayName != formattedName) {
        await user.updateDisplayName(formattedName);
      }

      if (user.email?.toLowerCase() != formattedEmail) {
        await user.verifyBeforeUpdateEmail(formattedEmail);
      }

      await _firestore.collection('users').doc(user.uid).update({
        'name': formattedName,
        'email': formattedEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'For security, please log out and log back in before changing your email.';
      }
      throw e.message ?? 'Failed to update email in Firebase Auth.';
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // forget password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email: $e';
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

}
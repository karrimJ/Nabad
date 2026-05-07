import 'package:firebase_auth/firebase_auth.dart';

/// Thrown by [AuthService] when an authentication operation fails.
///
/// Wraps Firebase errors with a user-friendly message so UI screens
/// do not need to import `firebase_auth` to display errors.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

/// Centralized authentication service backed by Firebase Auth.
///
/// Mirrors the architectural style of `lib/services/medication_service.dart`:
/// a plain Dart class wrapping a single Firebase API surface, exposing
/// async methods that either succeed or throw a typed [AuthException].
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Currently signed in user, or null if signed out.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth-state changes (signed in / signed out / user updates).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in with email and password.
  ///
  /// Returns the authenticated [User] on success.
  /// Throws [AuthException] with a human-readable message on failure.
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Login failed. Please try again.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e), code: e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Something went wrong: $e');
    }
  }

  /// Sends a password-reset email to the given address.
  ///
  /// Throws [AuthException] on failure (invalid email, user-not-found, etc).
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e), code: e.code);
    } catch (e) {
      throw AuthException('Could not send reset email: $e');
    }
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Maps Firebase Auth error codes to short, user-friendly messages.
  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'missing-email':
        return 'Please enter your email.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }
}
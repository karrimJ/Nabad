import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const String consentVersion = '1.0';

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

  Future<User> signInWithGoogle({
    bool privacyConsentGranted = false,
    bool healthDataConsentGranted = false,
    String source = 'login',
  }) async {
    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile')
          ..setCustomParameters({
            'prompt': 'select_account',
          });

        credential = await _auth.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn(
          scopes: ['email', 'profile'],
        ).signIn();

        if (googleUser == null) {
          throw const AuthException('Google sign-in was cancelled.');
        }

        final googleAuth = await googleUser.authentication;

        final firebaseCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(firebaseCredential);
      }

      return await _finishSocialSignIn(
        credential,
        privacyConsentGranted: privacyConsentGranted,
        healthDataConsentGranted: healthDataConsentGranted,
        source: source,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e), code: e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  Future<User> signInWithApple({
    bool privacyConsentGranted = false,
    bool healthDataConsentGranted = false,
    String source = 'login',
  }) async {
    try {
      final provider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final credential = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);

      return await _finishSocialSignIn(
        credential,
        privacyConsentGranted: privacyConsentGranted,
        healthDataConsentGranted: healthDataConsentGranted,
        source: source,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e), code: e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Apple sign-in failed: $e');
    }
  }

  Future<User> _finishSocialSignIn(
    UserCredential credential, {
    required bool privacyConsentGranted,
    required bool healthDataConsentGranted,
    required String source,
  }) async {
    final user = credential.user;

    if (user == null) {
      throw const AuthException('Social sign-in failed. Please try again.');
    }

    final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;

    if (isNewUser && (!privacyConsentGranted || !healthDataConsentGranted)) {
      try {
        await user.delete();
      } catch (_) {}

      await _auth.signOut();

      throw const AuthException(
        'This is a new social account. Please use the Sign Up screen and accept privacy consent first.',
      );
    }

    await _saveSocialUser(
      user: user,
      credential: credential,
      isNewUser: isNewUser,
      privacyConsentGranted: privacyConsentGranted,
      healthDataConsentGranted: healthDataConsentGranted,
      source: source,
    );

    return user;
  }

  Future<void> _saveSocialUser({
    required User user,
    required UserCredential credential,
    required bool isNewUser,
    required bool privacyConsentGranted,
    required bool healthDataConsentGranted,
    required String source,
  }) async {
    final now = FieldValue.serverTimestamp();

    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastLoginAt': now,
      'signInProvider': credential.additionalUserInfo?.providerId ?? 'social',
    };

    if (isNewUser) {
      data['createdAt'] = now;
    }

    if (privacyConsentGranted && healthDataConsentGranted) {
      data.addAll({
        'privacyConsentGranted': true,
        'privacyConsentVersion': consentVersion,
        'privacyConsentGrantedAt': now,
        'healthDataConsentGranted': true,
        'healthDataConsentVersion': consentVersion,
        'healthDataConsentGrantedAt': now,
      });
    }

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userRef.set(data, SetOptions(merge: true));

    if (privacyConsentGranted && healthDataConsentGranted) {
      await userRef.collection('privacyConsents').doc('current').set({
        'accepted': true,
        'version': consentVersion,
        'acceptedAt': now,
        'source': source,
        'provider': credential.additionalUserInfo?.providerId ?? 'social',
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'consentText':
            'User consented to Nabad collecting and storing account data, health profile data, vitals, medications, medical ID information, emergency contacts, wearable readings, SOS logs, appointments, notifications, uploaded files, and app activity needed to provide Nabad features.',
        'purposes': [
          'Create and manage user account',
          'Track vitals and health readings',
          'Manage medications and reminders',
          'Store medical ID and emergency information',
          'Support SOS and nearby medical services features',
          'Store wearable/device readings when connected',
          'Improve user safety and app reliability',
        ],
        'dataCategories': [
          'Email/account identifier',
          'Vitals readings',
          'Medication records',
          'Medical ID information',
          'Emergency contacts',
          'SOS logs and location when SOS is used',
          'Wearable/device readings',
          'Appointments and notifications',
          'Uploaded medical files if added by user',
        ],
        'withdrawalNotice':
            'User can request withdrawal/deletion from privacy settings or by contacting the Nabad team.',
      }, SetOptions(merge: true));
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      throw const AuthException('Please enter your email.');
    }

    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e), code: e.code);
    } catch (e) {
      throw AuthException('Could not send reset email: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    await _auth.signOut();
  }

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
        return 'This sign-in provider is not enabled in Firebase.';
      case 'popup-closed-by-user':
        return 'Sign-in popup was closed before finishing.';
      case 'cancelled-popup-request':
        return 'Another sign-in popup is already open.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }
}
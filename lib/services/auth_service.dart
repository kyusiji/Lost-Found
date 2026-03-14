// services/auth_service.dart
//
// Handles Firebase Authentication and Firestore user data.

import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user from Firebase Auth
  User? get currentFirebaseUser => _auth.currentUser;
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => currentFirebaseUser != null;

  // ══════════════════════════════════════════════════════════════════════
  // LOGIN
  // ══════════════════════════════════════════════════════════════════════

  /// Sign in with NCST email (or student number) and password.
  /// Returns a [UserModel] on success; throws [AuthException] on failure.
  Future<UserModel> login({
    required String emailOrStudentNumber,
    required String password,
  }) async {
    late String email;

    if (emailOrStudentNumber.contains('@')) {
      // It's an email
      email = emailOrStudentNumber;
    } else {
      // It's a student number, query Firestore to get the email
      try {
        final docSnapshot = await _firestore
            .collection('userMappings')
            .doc(emailOrStudentNumber)
            .get();
        if (!docSnapshot.exists) {
          throw const AuthException('Student number not found.');
        }
        final data = docSnapshot.data();
        email = data?['ncstEmail'] ?? '';
        if (email.isEmpty) {
          throw const AuthException(
              'User data incomplete. Please contact support.');
        }
      } on FirebaseException catch (e) {
        throw AuthException(
            'Failed to find user: ${e.message ?? 'unknown error'}');
      }
    }

    // authenticate user
    late UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }

    // fetch profile from Firestore
    try {
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!userDoc.exists) {
        throw const AuthException(
            'User data not found. Please contact support.');
      }
      final data = userDoc.data()!;
// Manually add the UID from the document ID
      _currentUser =
          UserModel.fromMap(data).copyWith(uid: credential.user!.uid);

      // Ensure user mapping exists (for existing users who login with email)
      final studentNum = data['studentNumber'] ?? '';
      final userEmail = data['ncstEmail'] ?? '';
      if (studentNum.isNotEmpty && userEmail.isNotEmpty) {
        try {
          final mappingDoc =
              await _firestore.collection('userMappings').doc(studentNum).get();
          if (!mappingDoc.exists) {
            // Create mapping for existing user
            await _firestore.collection('userMappings').doc(studentNum).set({
              'ncstEmail': userEmail,
            });
          }
        } catch (e) {
          // Don't fail login if mapping creation fails
          debugPrint('Warning: Could not create user mapping: $e');
        }
      }

      return _currentUser!;
    } on FirebaseException catch (e) {
      // permission denied / network / etc.
      throw AuthException(
          'Failed to load user profile: ${e.message ?? 'unknown error'}');
    } catch (e) {
      throw AuthException('Unexpected login error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // REGISTER
  // ══════════════════════════════════════════════════════════════════════

  /// Create a new Firebase Auth account and save user data to Firestore.
  Future<UserModel> register({
    required String surname,
    required String firstName,
    required String studentNumber,
    required String ncstEmail,
    required String password,
  }) async {
    try {
      // Check Firebase is initialized
      if (FirebaseAuth.instance == null) {
        throw Exception('Firebase not initialized');
      }

      // Step 1: Create Firebase Auth account
      print('📝 Step 1: Creating Firebase Auth account...');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: ncstEmail,
        password: password,
      );
      final userId = credential.user!.uid;
      print('✅ Step 1 Success: User created with UID: $userId');

      // Step 2: Update display name (optional, don't fail if this errors)
      print('📝 Step 2: Updating display name...');
      try {
        await credential.user!.updateDisplayName('$firstName $surname');
        print('✅ Step 2 Success: Display name updated');
      } catch (e) {
        print('⚠️  Step 2 Warning (non-critical): $e');
      }

      // Step 3: Save user data to Firestore
      print('📝 Step 3: Saving user data to Firestore...');
      try {
        await _firestore.collection('users').doc(userId).set({
          'surname': surname,
          'firstName': firstName,
          'studentNumber': studentNumber,
          'ncstEmail': ncstEmail,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create public mapping for login/password reset
        await _firestore.collection('userMappings').doc(studentNumber).set({
          'ncstEmail': ncstEmail,
        });

        print('✅ Step 3 Success: User data and mapping saved to Firestore');
      } catch (e) {
        print('❌ Step 3 Failed: $e');
        // If Firestore save fails, delete the Auth user to keep them in sync
        print('📝 Rolling back: Deleting Firebase Auth user...');
        await credential.user!.delete();
        print('✅ Rollback complete: Auth user deleted');

        throw AuthException(
            'Could not save user data to database. Check internet and try again. Error: $e');
      }

      // Step 4: Cache user in memory
      print('📝 Step 4: Caching user in memory...');
      _currentUser = UserModel(
        uid: userId,
        surname: surname,
        firstName: firstName,
        studentNumber: studentNumber,
        ncstEmail: ncstEmail,
        photoUrl: '', // Initialize with empty string
      );
      print('✅ Step 4 Success: User cached and registration complete!');
      return _currentUser!;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw AuthException(_mapFirebaseError(e.code));
    } on AuthException catch (e) {
      print('❌ Auth Exception: ${e.message}');
      rethrow;
    } catch (e, stack) {
      print('❌ Unexpected Error: $e');
      print('📋 Stack Trace: $stack');
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ══════════════════════════════════════════════════════════════════════

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }

  // ══════════════════════════════════════════════════════════════════════
  // CHANGE PASSWORD
  // ══════════════════════════════════════════════════════════════════════

  /// Change the current user's password.
  /// Requires re-authentication with current password for security.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentFirebaseUser == null) {
      throw const AuthException('No user logged in.');
    }

    try {
      // Re-authenticate with current password
      final credential = EmailAuthProvider.credential(
        email: currentFirebaseUser!.email!,
        password: currentPassword,
      );
      await currentFirebaseUser!.reauthenticateWithCredential(credential);

      // Update to new password
      await currentFirebaseUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    } catch (e) {
      throw AuthException('Failed to change password: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ══════════════════════════════════════════════════════════════════════

  Future<void> sendPasswordReset(String emailOrStudentNumber) async {
    late String email;

    if (emailOrStudentNumber.contains('@')) {
      // It's an email
      email = emailOrStudentNumber;
    } else {
      // It's a student number, query Firestore to get the email
      try {
        final docSnapshot = await _firestore
            .collection('userMappings')
            .doc(emailOrStudentNumber)
            .get();
        if (!docSnapshot.exists) {
          throw const AuthException('Student number not found.');
        }
        final data = docSnapshot.data();
        email = data?['ncstEmail'] ?? '';
        if (email.isEmpty) {
          throw const AuthException(
              'User data incomplete. Please contact support.');
        }
      } on FirebaseException catch (e) {
        throw AuthException(
            'Failed to find user: ${e.message ?? 'unknown error'}');
      }
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════

  /// Maps Firebase error codes to user-friendly messages.
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // UPDATE CACHED USER
  // ══════════════════════════════════════════════════════════════════════

  /// Update the cached current user with new data
  /// Use this after profile photo or other user data changes
  void updateCachedUser(UserModel updatedUser) {
    _currentUser = updatedUser;
    print('✅ Cached user updated: ${updatedUser.fullName}');
  }

  /// Refresh current user from Firestore
  /// Fetches latest data and updates _currentUser
  Future<UserModel?> refreshCurrentUser() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return null;

      final data = userDoc.data()!;
// Manually add the UID here too
      _currentUser = UserModel.fromMap(data).copyWith(uid: uid);

      print('✅ User refreshed from Firestore: ${_currentUser?.fullName}');
      return _currentUser;
    } catch (e) {
      print('❌ Error refreshing user: $e');
      return null;
    }
  }

  /// Fetch a user by UID from Firestore
  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return null;

      final data = userDoc.data()!;
      return UserModel.fromMap(data).copyWith(uid: uid);
    } catch (e) {
      print('❌ Error fetching user by UID: $e');
      return null;
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

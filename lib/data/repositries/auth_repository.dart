// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ============================================
  // EMAIL/PASSWORD AUTHENTICATION
  // ============================================

  /// Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('📧 Signing in with email: $email');

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      final user = userCredential.user;

      // Check if email is verified
      if (user != null && !user.emailVerified) {
        print('⚠️ Email not verified');
        throw Exception('Please verify your email before signing in.');
      }

      print('✅ Email sign in successful');
      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email.');
        case 'wrong-password':
          throw Exception('Incorrect password.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many attempts. Please try again later.');
        case 'invalid-credential':
          throw Exception('Invalid email or password.');
        default:
          throw Exception(e.message ?? 'Sign in failed.');
      }
    } catch (e) {
      print('❌ Error signing in with email: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('📧 Creating account for: $email');

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final user = userCredential.user;

      if (user != null) {
        // Update display name
        await user.updateDisplayName(name.trim());

        // Send email verification
        await user.sendEmailVerification();
        print('✅ Verification email sent');

        print('✅ Account created successfully');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account already exists with this email.');
        case 'weak-password':
          throw Exception('Password is too weak. Use at least 6 characters.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled.');
        default:
          throw Exception(e.message ?? 'Sign up failed.');
      }
    } catch (e) {
      print('❌ Error signing up with email: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      print('📧 Sending password reset email to: $email');

      await _auth.sendPasswordResetEmail(email: email.trim());

      print('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        default:
          throw Exception(e.message ?? 'Failed to send reset email.');
      }
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      rethrow;
    }
  }

  /// Resend email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('✅ Verification email sent');
      } else if (user?.emailVerified == true) {
        throw Exception('Email is already verified.');
      } else {
        throw Exception('No user is currently signed in.');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'too-many-requests':
          throw Exception(
            'Too many requests. Please wait before requesting another email.',
          );
        default:
          throw Exception(e.message ?? 'Failed to send verification email.');
      }
    } catch (e) {
      print('❌ Error sending verification email: $e');
      rethrow;
    }
  }

  /// Check if current user's email is verified
  Future<bool> isEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      print('❌ Error checking email verification: $e');
      return false;
    }
  }

  /// Re-authenticate with email and password (for sensitive operations)
  Future<bool> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ Re-authentication successful');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Re-authentication failed: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'wrong-password':
          throw Exception('Incorrect password.');
        case 'user-mismatch':
          throw Exception('Email does not match current user.');
        case 'invalid-credential':
          throw Exception('Invalid credentials.');
        default:
          throw Exception(e.message ?? 'Re-authentication failed.');
      }
    } catch (e) {
      print('❌ Error re-authenticating: $e');
      return false;
    }
  }

  /// Update email address
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user is signed in.');

      await user.verifyBeforeUpdateEmail(newEmail.trim());
      print('✅ Verification email sent to new address');
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already in use.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'requires-recent-login':
          throw Exception('Please sign in again to update your email.');
        default:
          throw Exception(e.message ?? 'Failed to update email.');
      }
    } catch (e) {
      print('❌ Error updating email: $e');
      rethrow;
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user is signed in.');

      await user.updatePassword(newPassword);
      print('✅ Password updated successfully');
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'weak-password':
          throw Exception('Password is too weak. Use at least 6 characters.');
        case 'requires-recent-login':
          throw Exception('Please sign in again to update your password.');
        default:
          throw Exception(e.message ?? 'Failed to update password.');
      }
    } catch (e) {
      print('❌ Error updating password: $e');
      rethrow;
    }
  }

  // ============================================
  // GOOGLE AUTHENTICATION
  // ============================================

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In...');

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ User canceled Google Sign-In');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      print('✅ Google sign in successful');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception(
            'An account already exists with this email using a different sign-in method.',
          );
        case 'invalid-credential':
          throw Exception('Invalid Google credentials.');
        case 'operation-not-allowed':
          throw Exception('Google sign-in is not enabled.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        default:
          throw Exception(e.message ?? 'Google sign in failed.');
      }
    } catch (e) {
      print('❌ Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Re-authenticate with Google (required for sensitive operations)
  Future<bool> reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);
      print('✅ Google re-authentication successful');
      return true;
    } catch (e) {
      print('❌ Error re-authenticating with Google: $e');
      return false;
    }
  }

  // ============================================
  // APPLE AUTHENTICATION (Optional - iOS)
  // ============================================

  /// Sign in with Apple
  Future<User?> signInWithApple() async {
    try {
      print('🍎 Starting Apple Sign-In...');

      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      final UserCredential userCredential = await _auth.signInWithProvider(
        appleProvider,
      );

      print('✅ Apple sign in successful');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception(
            'An account already exists with this email using a different sign-in method.',
          );
        case 'invalid-credential':
          throw Exception('Invalid Apple credentials.');
        case 'operation-not-allowed':
          throw Exception('Apple sign-in is not enabled.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        default:
          throw Exception(e.message ?? 'Apple sign in failed.');
      }
    } catch (e) {
      print('❌ Error signing in with Apple: $e');
      rethrow;
    }
  }

  // ============================================
  // FIRESTORE USER PROFILE MANAGEMENT
  // ============================================

  /// Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String name,
    String? photoUrl,
    String? bio,
    required List<String> interests,
    double? lat,
    double? lng,
  }) async {
    try {
      final user = AppUser(
        uid: uid,
        name: name,
        photoUrl: photoUrl,
        bio: bio,
        interests: interests,
        lat: lat,
        lng: lng,
      );

      await _firestore.collection('users').doc(uid).set(user.toJson());
      print('✅ User profile created in Firestore');
    } catch (e) {
      print('❌ Error creating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile from Firestore
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toJson());
      print('✅ User profile updated in Firestore');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  /// Check if user profile exists in Firestore
  Future<bool> userProfileExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking user profile: $e');
      return false;
    }
  }

  // ============================================
  // SIGN OUT & ACCOUNT DELETION
  // ============================================

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// Delete user account and all associated data
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user is signed in.');

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      print('✅ User data deleted from Firestore');

      // Delete user authentication
      await user.delete();
      print('✅ User authentication deleted');

      // Sign out from Google
      await _googleSignIn.signOut();
      print('✅ Signed out from Google');
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      if (e.code == 'requires-recent-login') {
        throw Exception('Please sign in again to delete your account.');
      }
      throw Exception(e.message ?? 'Failed to delete account.');
    } catch (e) {
      print('❌ Error deleting account: $e');
      rethrow;
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get current authentication provider
  String? getCurrentAuthProvider() {
    final user = _auth.currentUser;
    if (user == null) return null;

    for (var info in user.providerData) {
      if (info.providerId == 'google.com') return 'Google';
      if (info.providerId == 'apple.com') return 'Apple';
      if (info.providerId == 'password') return 'Email';
    }
    return null;
  }

  /// Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  /// Get user ID
  String? getUserId() {
    return _auth.currentUser?.uid;
  }

  /// Get user email
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Get user display name
  String? getUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  /// Get user photo URL
  String? getUserPhotoUrl() {
    return _auth.currentUser?.photoURL;
  }
}

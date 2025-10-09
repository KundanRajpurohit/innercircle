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

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
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

      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with Apple (Optional - for iOS)
  Future<User?> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      final UserCredential userCredential = await _auth.signInWithProvider(
        appleProvider,
      );

      return userCredential.user;
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }

  // Create user profile in Firestore
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
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toJson());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Check if user profile exists
  Future<bool> userProfileExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user profile: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user authentication
        await user.delete();

        // Sign out from Google
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  // Re-authenticate user (required for sensitive operations)
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
      return true;
    } catch (e) {
      print('Error re-authenticating: $e');
      return false;
    }
  }
}

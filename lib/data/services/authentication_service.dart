import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthenticationService {
  static final AuthenticationService _instance = AuthenticationService._internal();

  factory AuthenticationService() {
    return _instance;
  }

  AuthenticationService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase already initialized: $e');
    }
  }

  // Email & Password Registration
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String userType,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final now = DateTime.now();
      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        userType: userType,
        isEmailVerified: false,
        createdAt: now,
        lastLogin: now,
        stats: {
          'totalScans': 0,
          'recommendationsSaved': 0,
          'forumContributions': 0,
          'cropMonitored': 0,
        },
      );

      // Save user to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toJson());

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email & Password Login
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      final user = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

      // Update last login
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Check if user exists
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      UserModel user;
      if (userDoc.exists) {
        user = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        // Update last login
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });
      } else {
        // Create new user
        final now = DateTime.now();
        user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          isEmailVerified: userCredential.user!.emailVerified,
          userType: 'farmer',
          createdAt: now,
          lastLogin: now,
          stats: {
            'totalScans': 0,
            'recommendationsSaved': 0,
            'forumContributions': 0,
            'cropMonitored': 0,
          },
        );
        await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toJson());
      }

      return user;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get current user model from Firestore
  Future<UserModel?> getCurrentUserModel() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user model: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
    String? location,
    String? bio,
    String? userType,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (location != null) updates['location'] = location;
      if (bio != null) updates['bio'] = bio;
      if (userType != null) updates['userType'] = userType;

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update user stats
  Future<void> updateUserStats({
    required String uid,
    String? statKey,
    required int incrementValue,
  }) async {
    try {
      if (statKey == null) return;
      await _firestore.collection('users').doc(uid).update({
        'stats.$statKey': FieldValue.increment(incrementValue),
      });
    } catch (e) {
      throw Exception('Failed to update user stats: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}

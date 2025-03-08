// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart'; // Ensure correct path
import 'database_service.dart';
import '../models/user.dart'; // Ensure correct path

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthService() {
    // Listen to authentication state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  final DatabaseService _databaseService = DatabaseService();

  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      throw Exception('Failed to initialize Firebase: $e');
    }
  }

  bool get isLoggedIn => currentUser != null;

  // Handle authentication state changes
  void _onAuthStateChanged(User? user) {
    print('Auth state changed: ${user?.email}');
    notifyListeners();
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Ensure the user object exists
      if (userCredential.user == null) {
        throw Exception('No user data received after sign in');
      }

      print('Successfully signed in: ${userCredential.user?.email}');
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      print('General Error during sign in: $e');
      if (e.toString().contains('PigeonUserDetails')) {
        // Handle the specific type casting error
        throw Exception('Authentication failed: Unable to process user details');
      }
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      print('Attempting to create account with email: $email');
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();
      
      print('Successfully created account: ${userCredential.user?.email}');
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      print('General Error during sign up: $e');
      throw Exception('Failed to create account: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign In process');
      
      // Force sign out first to clear any existing sessions
      await _googleSignIn.signOut();
      
      // Begin sign in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Google Sign In cancelled by user');
        return null;
      }

      print('Getting Google auth details');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        print('Signing in to Firebase with Google credential');
        // Sign in to Firebase
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        
        if (userCredential.user == null) {
          throw Exception('No user data received from Google sign in');
        }

        // Wait for a short duration to ensure Firebase auth state is updated
        await Future.delayed(Duration(milliseconds: 500));

        print('Successfully signed in with Google: ${userCredential.user?.email}');
        notifyListeners();
        return userCredential;
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth Exception during Google sign in: ${e.code}');
        throw _handleAuthException(e);
      }
    } catch (e) {
      print('Error during Google sign in: $e');
      if (e.toString().contains('PigeonUserDetails')) {
        // Check if the user is actually signed in despite the error
        if (_auth.currentUser != null) {
          print('User is signed in despite PigeonUserDetails error');
          // Instead of creating a UserCredential, we'll return null and let the UI check currentUser
          notifyListeners();
          return null;
        }
      }
      throw Exception('Failed to sign in with Google. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      print('Signing out');
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('Successfully signed out');
      notifyListeners();
    } catch (e) {
      print('Error during sign out: $e');
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    print('Handling auth exception: ${e.code}');
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Link Email and Password to existing Google Sign-In account
  Future<void> linkWithEmail(String email, String password) async {
    if (currentUser == null) {
      throw Exception('No user is currently signed in.');
    }

    try {
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);
      await currentUser!.linkWithCredential(credential);
      print('Successfully linked email and password to Google account.');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during linking: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      print('General Exception during linking: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verify user data
      if (userCredential.user == null) {
        throw Exception('No user data received');
      }
      
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e.toString().contains('PigeonUserDetails')) {
        throw Exception('Unable to process user details. Please try again.');
      }
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
}
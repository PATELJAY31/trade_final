// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart'; // Ensure correct path
import 'database_service.dart';
import '../models/user.dart'; // Ensure correct path

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Initialize GoogleSignIn
  User? _user;

  AuthService() {
    // Listen to authentication state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get currentUser => _user;

  // Handle authentication state changes
  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }

  final DatabaseService _databaseService = DatabaseService();

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized');
  }

  bool get isLoggedIn => currentUser != null;

  // Expose the authStateChanges stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Email and Password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      print('Signing in with email: $email');
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      notifyListeners();
      print('Signed in user: ${currentUser?.email}');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      print('General Exception: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Sign up with Email and Password
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      print('Signing up with email: $email');
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Create a new user document in Firestore
      await _databaseService.createUser(UserModel(
        uid: currentUser!.uid,
        name: '',
        email: email,
        phone: '',
      ));
      print('User document created for: ${currentUser?.email}');

      notifyListeners();
      print('Signup successful for: ${currentUser?.email}');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      print('General Exception: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      print('Initiating Google Sign-In');
      await _googleSignIn.signOut(); // Sign out existing sessions

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('User cancelled Google Sign-In');
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      UserCredential cred = await _auth.signInWithCredential(credential);

      print('Signed in user with Google: ${currentUser?.email}');

      // Check if user exists in Firestore
      bool userExists =
          await _databaseService.checkUserExists(currentUser!.uid);
      print('User exists in Firestore: $userExists');
      if (!userExists) {
        // Create new user document
        await _databaseService.createUser(UserModel(
          uid: currentUser!.uid,
          name: currentUser!.displayName ?? '',
          email: currentUser!.email ?? '',
          phone: '',
        ));
        print('User document created for Google user: ${currentUser?.email}');
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('Error in signInWithGoogle: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // Ensure GoogleSignIn is also signed out
    notifyListeners();
    print('User signed out');
  }

  // Handle Firebase Authentication Exceptions
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'The email is already in use by another account.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An undefined Error happened.';
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
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      print('General Exception during linking: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      notifyListeners();
    } catch (e) {
      print('AuthService: SignIn Error: $e');
      throw e;
    }
  }

  Future<void> signUp(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      // Optionally, add user to your database
      // await _databaseService.addUser(currentUser!);

      notifyListeners();
    } catch (e) {
      print('AuthService: SignUp Error: $e');
      throw e;
    }
  }
}
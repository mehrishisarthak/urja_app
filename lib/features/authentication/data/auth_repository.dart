import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (!_isGoogleInitialized) {
      await _googleSignIn.initialize();
      _isGoogleInitialized = true;
    }
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email', 
        'profile'
      ]);
      final googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );
      return await _auth.signInWithCredential(credential);

    } on GoogleSignInException catch (e) {
      if (e.code.name == 'canceled' || e.code.name == 'SIGN_IN_CANCELLED') {
        return null; 
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_isGoogleInitialized) {
       await _googleSignIn.disconnect();
    }
    await _auth.signOut();
  }
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
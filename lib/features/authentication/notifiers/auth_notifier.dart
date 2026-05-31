import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

class AuthFormState {
  final bool isLoading;
  final String? errorMessage;
  
  AuthFormState({this.isLoading = false, this.errorMessage});
}

class AuthNotifier extends Notifier<AuthFormState> {
  @override
  AuthFormState build() {
    return AuthFormState();
  }

  Future<void> login(String email, String password) async {
    state = AuthFormState(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(email, password);
      state = AuthFormState(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = AuthFormState(isLoading: false, errorMessage: e.message);
    }
  }

  Future<void> signup(String email, String password) async {
    state = AuthFormState(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(email, password);
      state = AuthFormState(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = AuthFormState(isLoading: false, errorMessage: e.message);
    }
  }

  Future<void> googleLogin() async {
    state = AuthFormState(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      state = AuthFormState(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = AuthFormState(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = AuthFormState(isLoading: false, errorMessage: "Google Sign-in failed");
    }
  }
  
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
  }
}

final authControllerProvider = NotifierProvider<AuthNotifier, AuthFormState>(() {
  return AuthNotifier();
});
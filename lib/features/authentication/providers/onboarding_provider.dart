// lib/features/authentication/providers/onboarding_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../notifiers/auth_notifier.dart';

class UserProfile {
  final String? colonyId;
  final int coinsRedeemed;

  UserProfile({this.colonyId, this.coinsRedeemed = 0});

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) return UserProfile();
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      colonyId: data['colonyId'] as String?,
      coinsRedeemed: data['coinsRedeemed'] ?? 0,
    );
  }
}

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value(null); 
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => UserProfile.fromFirestore(doc));
});

enum OnboardingStatus {
  checking,                 // Splash screen loading state
  unauthenticated,          // Not logged in at all
  emailVerificationPending, // Logged in, but email is not verified
  needsColonySetup,         // Logged in, verified, but has no Colony ID
  fullyOnboarded,           // Good to go!
}

final onboardingStatusProvider = Provider<OnboardingStatus>((ref) {
  final user = ref.watch(authStateProvider).value;
  
  if (user == null) {
    return OnboardingStatus.unauthenticated;
  }

  if (!user.emailVerified) {
    return OnboardingStatus.emailVerificationPending;
  }

  final profileState = ref.watch(userProfileProvider);
  if (profileState.isLoading) {
    return OnboardingStatus.checking; 
  }

  final userProfile = profileState.value;
  if (userProfile?.colonyId == null || userProfile!.colonyId!.isEmpty) {
    return OnboardingStatus.needsColonySetup;
  }
  return OnboardingStatus.fullyOnboarded;
});
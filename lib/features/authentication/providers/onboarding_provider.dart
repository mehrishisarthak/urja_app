import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urja/core/services/shared_preferences_service.dart';
import 'package:urja/features/authentication/providers/user_profile_provider.dart';
import '../notifiers/auth_notifier.dart';

enum OnboardingStatus {
  checking,                 // Splash screen loading state
  firstTimeVisitor,         // NEW: Has never seen the welcome carousel
  unauthenticated,          // Not logged in at all
  emailVerificationPending, // Logged in, but email is not verified
  needsColonySetup,         // Logged in, verified, but has no Colony ID
  fullyOnboarded,           // Good to go!
}

final onboardingStatusProvider = Provider<OnboardingStatus>((ref) {
  final hasSeenOnboarding = ref.read(sharedPrefsServiceProvider).hasSeenOnboarding;
  
  if (!hasSeenOnboarding) {
    return OnboardingStatus.firstTimeVisitor;
  }

  // 2. If they have seen it, proceed to your existing Firebase logic
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
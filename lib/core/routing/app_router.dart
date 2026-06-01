import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth Features
import 'package:urja/features/authentication/presentation/login.dart';
import 'package:urja/features/authentication/presentation/signup.dart';
import 'package:urja/features/authentication/presentation/verify_email_screen.dart'; 

// Waste Tracking / Colony Features
import 'package:urja/features/waste_tracking/presentation/colony_code_screen.dart';
import 'package:urja/features/colony_ledger/presentation/dashboard_screen.dart';

// Import your Onboarding FSM provider here
import 'package:urja/features/authentication/providers/onboarding_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // 1. The FSM is now LIVE. Any changes to Auth or Firestore will instantly rebuild this router.
  final onboardingStatus = ref.watch(onboardingStatusProvider);

  return GoRouter(
    initialLocation: '/dashboard', 
    redirect: (context, state) {
      final currentPath = state.matchedLocation;
      
      final isGoingToLogin = currentPath == '/login' || currentPath == '/signup';
      final isGoingToVerify = currentPath == '/verify-email';
      final isGoingToSetup = currentPath == '/setup-colony';

      switch (onboardingStatus) {
        case OnboardingStatus.unauthenticated:
          // Force to login/signup
          return isGoingToLogin ? null : '/login';

        case OnboardingStatus.emailVerificationPending:
          // Force to verify email
          return isGoingToVerify ? null : '/verify-email';

        case OnboardingStatus.needsColonySetup:
          // Force to colony setup
          return isGoingToSetup ? null : '/setup-colony';

        case OnboardingStatus.fullyOnboarded:
          // If fully onboarded, block them from seeing auth screens again
          if (isGoingToLogin || isGoingToVerify || isGoingToSetup) {
            return '/dashboard';
          }
          return null; 
          
        case OnboardingStatus.checking:
          // Show splash screen while Firebase loads
          return '/splash'; 
      }
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.green)), // Styled for Urja
        ),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/setup-colony',
        builder: (context, state) => const ColonyCodeScreen(),
      ),
    ],
  );
});
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urja/carousal_screen.dart';

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
  late final GoRouter router;

  router = GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      // Always read the latest status — never captured in a stale closure.
      final onboardingStatus = ref.read(onboardingStatusProvider);
      final currentPath = state.matchedLocation;

      final isGoingToLogin = currentPath == '/login' || currentPath == '/signup';
      final isGoingToVerify = currentPath == '/verify-email';
      final isGoingToSetup = currentPath == '/setup-colony';
      final isGoingToWelcome = currentPath == '/welcome';

      switch (onboardingStatus) {
        case OnboardingStatus.firstTimeVisitor:
          return isGoingToWelcome ? null : '/welcome';

        case OnboardingStatus.unauthenticated:
          return isGoingToLogin ? null : '/login';

        case OnboardingStatus.emailVerificationPending:
          return isGoingToVerify ? null : '/verify-email';

        case OnboardingStatus.needsColonySetup:
          return isGoingToSetup ? null : '/setup-colony';

        case OnboardingStatus.fullyOnboarded:
          // Also redirect away from /splash — it's the transient loading screen
          // and must not be the final destination for a fully onboarded user.
          final isBlockedPath = isGoingToLogin || isGoingToVerify ||
              isGoingToSetup || isGoingToWelcome || currentPath == '/splash';
          return isBlockedPath ? '/dashboard' : null;

        case OnboardingStatus.checking:
          return currentPath == '/splash' ? null : '/splash';
      }
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const CarousalScreen(),
      ),
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
          body: Center(child: CircularProgressIndicator(color: Colors.green)),
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

  // When auth/profile/onboarding state changes, tell the existing router to
  // re-evaluate its redirect — no need to recreate the whole GoRouter.
  ref.listen(onboardingStatusProvider, (_, __) => router.refresh());

  ref.onDispose(router.dispose);

  return router;
});
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:urja/core/services/shared_preferences_service.dart' show sharedPrefsServiceProvider;

class CarousalScreen extends ConsumerStatefulWidget {
  const CarousalScreen({super.key});

  @override
  ConsumerState<CarousalScreen> createState() => _CarousalScreenState();
}

class _CarousalScreenState extends ConsumerState<CarousalScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(sharedPrefsServiceProvider).setHasSeenOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(bottom: 80),
          child: PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [
              // --- SLIDE 1 ---
              _buildPage(
                theme: theme,
                lottiePath: 'assets/lottie/recycle.json',
                title: 'Recycle with Purpose',
                description: 'Dispose of your dry and wet waste responsibly. Every contribution helps make your society greener.',
              ),
              // --- SLIDE 2 ---
              _buildPage(
                theme: theme,
                lottiePath: 'assets/lottie/coins.json',
                title: 'Earn Urja Coins',
                description: 'Get rewarded for your eco-friendly habits. Track your colony\'s total earnings in real-time.',
              ),
              // --- SLIDE 3 ---
              _buildPage(
                theme: theme,
                lottiePath: 'assets/lottie/colony.json',
                title: 'Upgrade Your Colony',
                description: 'Redeem your coins for maintenance discounts, premium parking, and exclusive society perks.',
              ),
            ],
          ),
        ),
      ),
      // --- THE BOTTOM NAVIGATION BAR ---
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        height: 80,
        color: theme.scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _controller.jumpToPage(2),
              child: Text(
                'Skip',
                style: TextStyle(color: colorScheme.onSurface.withAlpha(150)),
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: ExpandingDotsEffect(
                activeDotColor: colorScheme.primary,
                dotColor: colorScheme.primaryContainer,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3, 
              ),
            ),
            isLastPage
                ? FilledButton(
                    onPressed: _completeOnboarding,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Get Started'),
                  )
                : FilledButton.tonal(
                    onPressed: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Next'),
                  ),
          ],
        ),
      ),
    );
  }

  // --- THE UPDATED HELPER COMPONENT ---
  Widget _buildPage({
    required ThemeData theme,
    required String lottiePath, // Swapped IconData for String
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The Lottie Animation replaces the static Icon container
          SizedBox(
            height: 250, // Adjust this height based on your specific Lottie files
            child: Lottie.asset(
              lottiePath,
              repeat: true, // Keeps the animation looping
              reverse: false,
              animate: true,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withAlpha(200),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
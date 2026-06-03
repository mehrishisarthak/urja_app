import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:urja/core/services/shared_preferences_service.dart';
import 'package:urja/features/authentication/providers/onboarding_provider.dart';

class CarousalScreen extends ConsumerStatefulWidget {
  const CarousalScreen({super.key});

  @override
  ConsumerState<CarousalScreen> createState() => _CarousalScreenState();
}

class _CarousalScreenState extends ConsumerState<CarousalScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PageData(
      lottiePath: 'assets/lottie/recycle.json',
      title: 'Recycle with Purpose',
      description:
          'Dispose of your dry and wet waste responsibly. Every contribution helps make your society greener.',
    ),
    _PageData(
      lottiePath: 'assets/lottie/coins.json',
      title: 'Earn Urja Coins',
      description:
          'Get rewarded for your eco-friendly habits. Track your colony\'s total earnings in real-time.',
    ),
    _PageData(
      lottiePath: 'assets/lottie/colony.json',
      title: 'Upgrade Your Colony',
      description:
          'Redeem your coins for maintenance discounts, premium parking, and exclusive society perks.',
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    await ref.read(sharedPrefsServiceProvider).setHasSeenOnboarding();
    ref.read(hasSeenOnboardingProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button row — sits above the slides, never overlaps
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AnimatedOpacity(
                    opacity: _isLastPage ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: _isLastPage
                          ? null
                          : () => _controller.animateToPage(
                                _pages.length - 1,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: colorScheme.onSurface.withAlpha(140),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Slides — takes all remaining space
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) => _SlidePage(
                  data: _pages[index],
                  animationHeight: size.height * 0.32,
                ),
              ),
            ),

            // Bottom controls — always visible, never floats over content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: colorScheme.primary,
                      dotColor: colorScheme.primaryContainer,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLastPage
                        ? SizedBox(
                            key: const ValueKey('get_started'),
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              onPressed: _onGetStarted,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            key: const ValueKey('next'),
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.tonal(
                              onPressed: () => _controller.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              ),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final String lottiePath;
  final String title;
  final String description;

  const _PageData({
    required this.lottiePath,
    required this.title,
    required this.description,
  });
}

class _SlidePage extends StatelessWidget {
  final _PageData data;
  final double animationHeight;

  const _SlidePage({required this.data, required this.animationHeight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: animationHeight,
            child: Lottie.asset(
              data.lottiePath,
              repeat: true,
              animate: true,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: colorScheme.onSurface.withAlpha(180),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

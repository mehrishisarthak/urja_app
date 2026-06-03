import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/colony_ledger_notifier.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class _Brand {
  final String name;
  final String offer;
  final int coins;
  final Color color;
  final String logoPath;

  const _Brand({
    required this.name,
    required this.offer,
    required this.coins,
    required this.color,
    required this.logoPath,
  });
}

// Just the deals you actually want to show
const _activeDeals = [
  _Brand(
    name: 'Swiggy',
    offer: 'Free delivery × 3 orders',
    coins: 100,
    color: Color(0xFFE65100),
    logoPath: 'assets/swiggy_logo.png',
  ),
  _Brand(
    name: 'Amazon',
    offer: '₹100 cashback on ₹500+',
    coins: 200,
    color: Color(0xFF00838F),
    logoPath: 'assets/amazon_logo.png',
  ),
  _Brand(
    name: 'Paytm',
    offer: '10% cashback on mobile recharge & bill payments',
    coins: 120,
    color: Color(0xFF5C6BC0),
    logoPath: 'assets/paytm_logo.png',
  ),
];

// Coming soon gift cards
const _giftCards = [
  _Brand(
    name: 'Amazon Pay',
    offer: '₹500 Gift Card',
    coins: 1000,
    color: Color(0xFF00838F),
    logoPath: 'assets/amazon_logo.png',
  ),
];

// ─── RewardsScreen ────────────────────────────────────────────────────────────

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  
  // Handle the redemption and show the coupon dialog
  Future<void> _handleRedeem(_Brand brand, int availableCoins) async {
    try {
      // Trigger the redemption via Riverpod
      await ref.read(redemptionProvider.notifier).redeemCoins(brand.coins, availableCoins);
      
      // Ensure the widget is still mounted before showing the dialog
      if (!mounted) return;

      // Generate a random 6-digit coupon code
      final randomCode = 'URJA-${Random().nextInt(900000) + 100000}';

      showDialog(
        context: context,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
            title: Text(
              'Deal Claimed!',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your offer from ${brand.name} is ready.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(180)
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(100),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary.withAlpha(50), style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'COUPON CODE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        randomCode,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got it!'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Redemption failed
      debugPrint('Redemption failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ledger = ref.watch(ledgerProvider);
    final isRedeeming = ref.watch(redemptionProvider);

    if (ledger.isLoading) {
      return Center(child: CircularProgressIndicator(color: colorScheme.primary));
    }

    return ListView(
      children: [
        // ── Wallet card ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: _WalletCard(ledger: ledger),
        ),

        // ── Active Deals ─────────────────────────────────────────────────────
        const _SectionHeader(title: 'Active Deals'),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 8),
            itemCount: _activeDeals.length,
            itemBuilder: (_, i) {
              final brand = _activeDeals[i];
              return _BrandCard(
                brand: brand,
                availableCoins: ledger.availableCoins,
                isRedeeming: isRedeeming,
                onRedeem: () => _handleRedeem(brand, ledger.availableCoins),
              );
            },
          ),
        ),

        const SizedBox(height: 32),

        // ── Gift Cards (Coming Soon) ─────────────────────────────────────────
        const _SectionHeader(title: 'Gift Cards (Coming Soon)'),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 8),
            itemCount: _giftCards.length,
            itemBuilder: (_, i) {
              return _BrandCard(
                brand: _giftCards[i],
                availableCoins: ledger.availableCoins,
                isRedeeming: false,
                isComingSoon: true, // Flags this card as disabled
                onRedeem: () {},
              );
            },
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

// ─── Brand card ───────────────────────────────────────────────────────────────

class _BrandCard extends StatelessWidget {
  final _Brand brand;
  final int availableCoins;
  final bool isRedeeming;
  final bool isComingSoon;
  final VoidCallback onRedeem;

  const _BrandCard({
    required this.brand,
    required this.availableCoins,
    required this.isRedeeming,
    this.isComingSoon = false,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canAfford = availableCoins >= brand.coins;

    return Container(
      width: 156, // Slightly widened for breathing room
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8), // Softer, cleaner shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored logo + name section
            Container(
              height: 105,
              color: isComingSoon 
                  ? colorScheme.surfaceContainerHighest.withAlpha(100) 
                  : brand.color.withAlpha(18),
              child: Stack(
                children: [
                  // "Urja Perk" label
                  if (!isComingSoon)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PARTNER',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  // Logo + name centered
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: isComingSoon 
                              ? Opacity(
                                  opacity: 0.4,
                                  child: Image.asset(brand.logoPath, fit: BoxFit.contain),
                                )
                              : Image.asset(
                                  brand.logoPath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.image_not_supported, color: brand.color),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            brand.name,
                            style: TextStyle(
                              color: isComingSoon ? colorScheme.onSurface.withAlpha(100) : brand.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Offer + coin + button section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        brand.offer,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isComingSoon 
                              ? colorScheme.onSurface.withAlpha(100)
                              : colorScheme.onSurface.withAlpha(170),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 14,
                          color: isComingSoon 
                              ? colorScheme.onSurface.withAlpha(80)
                              : (canAfford ? Colors.amber.shade700 : colorScheme.error),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${brand.coins}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isComingSoon
                                  ? colorScheme.onSurface.withAlpha(80)
                                  : (canAfford ? colorScheme.primary : colorScheme.error),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 28,
                          child: FilledButton(
                            onPressed: (canAfford && !isRedeeming && !isComingSoon) ? onRedeem : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: brand.color,
                              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isRedeeming
                                ? SizedBox(
                                    height: 12,
                                    width: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.onPrimary,
                                    ),
                                  )
                                : Text(
                                    isComingSoon ? 'Soon' : 'Get', 
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isComingSoon ? colorScheme.onSurface.withAlpha(120) : Colors.white,
                                    )
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Wallet card ──────────────────────────────────────────────────────────────

class _WalletCard extends StatelessWidget {
  final LedgerState ledger;
  const _WalletCard({required this.ledger});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'AVAILABLE BALANCE',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimary.withAlpha(180),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.stars_rounded, color: colorScheme.secondary, size: 42),
              const SizedBox(width: 10),
              Text(
                '${ledger.availableCoins}',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Colony Total: ${ledger.colonyTotalCoins} coins',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}
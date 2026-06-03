import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/colony_ledger_notifier.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class _Brand {
  final String name;
  final String offer;
  final int coins;
  final Color color;
  final IconData icon;

  const _Brand({
    required this.name,
    required this.offer,
    required this.coins,
    required this.color,
    required this.icon,
  });
}

class _Category {
  final String title;
  final List<_Brand> brands;
  const _Category({required this.title, required this.brands});
}

const _categories = [
  _Category(
    title: 'Society Perks',
    brands: [
      _Brand(name: 'Maintenance', offer: '10% off monthly bill', coins: 150, color: Color(0xFF2E7D32), icon: Icons.receipt_long_outlined),
      _Brand(name: 'Parking Upgrade', offer: 'Premium spot · weekend', coins: 300, color: Color(0xFF1565C0), icon: Icons.local_parking_outlined),
      _Brand(name: 'Gym Access', offer: 'Full-month club pass', coins: 400, color: Color(0xFF6A1B9A), icon: Icons.fitness_center_outlined),
      _Brand(name: 'Pool Entry', offer: 'Weekend pool access', coins: 200, color: Color(0xFF00695C), icon: Icons.pool_outlined),
      _Brand(name: 'Guest Parking', offer: '5 visitor passes', coins: 100, color: Color(0xFF4527A0), icon: Icons.directions_car_outlined),
    ],
  ),
  _Category(
    title: 'Food & Dining',
    brands: [
      _Brand(name: 'Swiggy', offer: 'Free delivery × 3 orders', coins: 100, color: Color(0xFFE65100), icon: Icons.delivery_dining_rounded),
      _Brand(name: 'Zomato', offer: '20% off your next order', coins: 80, color: Color(0xFFC62828), icon: Icons.restaurant_rounded),
      _Brand(name: 'BigBasket', offer: '10% off groceries', coins: 120, color: Color(0xFF2E7D32), icon: Icons.shopping_basket_rounded),
      _Brand(name: 'Blinkit', offer: 'Free delivery on 2 orders', coins: 60, color: Color(0xFFF9A825), icon: Icons.bolt_rounded),
    ],
  ),
  _Category(
    title: 'Shopping',
    brands: [
      _Brand(name: 'Amazon', offer: '₹100 cashback on ₹500+', coins: 200, color: Color(0xFF00838F), icon: Icons.shopping_bag_rounded),
      _Brand(name: 'Myntra', offer: '30% off fashion picks', coins: 250, color: Color(0xFFAD1457), icon: Icons.checkroom_outlined),
      _Brand(name: 'Flipkart', offer: '15% off electronics', coins: 180, color: Color(0xFF1565C0), icon: Icons.phone_android_outlined),
      _Brand(name: 'Nykaa', offer: 'Beauty deals bundle', coins: 160, color: Color(0xFF880E4F), icon: Icons.face_retouching_natural_outlined),
    ],
  ),
  _Category(
    title: 'Health & Eco',
    brands: [
      _Brand(name: 'Mamaearth', offer: 'Natural skincare kit', coins: 150, color: Color(0xFF388E3C), icon: Icons.spa_outlined),
      _Brand(name: 'Himalaya', offer: 'Herbal products pack', coins: 120, color: Color(0xFF00695C), icon: Icons.local_florist_outlined),
      _Brand(name: 'Organic Tatva', offer: 'Fresh produce box', coins: 80, color: Color(0xFF558B2F), icon: Icons.agriculture_outlined),
      _Brand(name: 'EcoSport', offer: 'Sustainable gear deal', coins: 200, color: Color(0xFF1B5E20), icon: Icons.directions_run_rounded),
    ],
  ),
];

// ─── RewardsScreen ────────────────────────────────────────────────────────────

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: _WalletCard(ledger: ledger),
        ),

        // ── Category sections ────────────────────────────────────────────────
        for (final category in _categories)
          _CategorySection(
            category: category,
            availableCoins: ledger.availableCoins,
            isRedeeming: isRedeeming,
            onRedeem: (cost) =>
                ref.read(redemptionProvider.notifier).redeemCoins(cost, ledger.availableCoins),
          ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Category section ─────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final _Category category;
  final int availableCoins;
  final bool isRedeeming;
  final void Function(int cost) onRedeem;

  const _CategorySection({
    required this.category,
    required this.availableCoins,
    required this.isRedeeming,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
        ),

        // Horizontal brand cards
        SizedBox(
          height: 178,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 8),
            itemCount: category.brands.length,
            itemBuilder: (_, i) {
              final brand = category.brands[i];
              return _BrandCard(
                brand: brand,
                availableCoins: availableCoins,
                isRedeeming: isRedeeming,
                onRedeem: () => onRedeem(brand.coins),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Brand card ───────────────────────────────────────────────────────────────

class _BrandCard extends StatelessWidget {
  final _Brand brand;
  final int availableCoins;
  final bool isRedeeming;
  final VoidCallback onRedeem;

  const _BrandCard({
    required this.brand,
    required this.availableCoins,
    required this.isRedeeming,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canAfford = availableCoins >= brand.coins;

    return Container(
      width: 148,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored icon + name section
            Container(
              height: 95,
              color: brand.color.withAlpha(18),
              child: Stack(
                children: [
                  // "Urja Perk" label
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Urja Perk',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  // Icon + name centered
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: brand.color.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(brand.icon, color: brand.color, size: 26),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            brand.name,
                            style: TextStyle(
                              color: brand.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
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
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        brand.offer,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withAlpha(155),
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 13,
                          color: canAfford ? Colors.amber.shade700 : colorScheme.error,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${brand.coins}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: canAfford ? colorScheme.primary : colorScheme.error,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 26,
                          child: FilledButton(
                            onPressed: (canAfford && !isRedeeming) ? onRedeem : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: brand.color,
                              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                : const Text('Get', style: TextStyle(fontSize: 11)),
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
            color: colorScheme.primary.withAlpha(60),
            blurRadius: 18,
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.stars_rounded, color: colorScheme.secondary, size: 38),
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
          const SizedBox(height: 12),
          Text(
            'Colony Total: ${ledger.colonyTotalCoins} coins',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}

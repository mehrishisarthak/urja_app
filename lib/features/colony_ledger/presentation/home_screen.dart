import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../notifiers/colony_ledger_notifier.dart';

// ─── Deal data ────────────────────────────────────────────────────────────────

class _Deal {
  final String name;
  final String tagline;
  final String offer;
  final IconData icon;
  final int coins;
  final List<Color> colors;

  const _Deal({
    required this.name,
    required this.tagline,
    required this.offer,
    required this.icon,
    required this.coins,
    required this.colors,
  });
}

const _deals = [
  _Deal(
    name: 'Amazon Pay',
    tagline: 'Shop & Save',
    offer: '₹100 cashback on grocery orders above ₹500',
    icon: Icons.shopping_bag_rounded,
    coins: 200,
    colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
  ),
  _Deal(
    name: 'BigBasket',
    tagline: 'Fresh & Organic',
    offer: 'Free delivery + 10% off on your next order',
    icon: Icons.shopping_basket_rounded,
    coins: 150,
    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
  ),
  _Deal(
    name: 'Swiggy',
    tagline: 'Food Delivered Fast',
    offer: 'Free delivery on your next 3 food orders',
    icon: Icons.delivery_dining_rounded,
    coins: 100,
    colors: [Color(0xFFFFA726), Color(0xFFE65100)],
  ),
  _Deal(
    name: 'Paytm',
    tagline: 'Pay Smarter',
    offer: '10% cashback on mobile recharge & bill payments',
    icon: Icons.smartphone_rounded,
    coins: 120,
    colors: [Color(0xFF5C6BC0), Color(0xFF1A237E)],
  ),
  _Deal(
    name: 'BookMyShow',
    tagline: 'Entertainment Awaits',
    offer: 'Buy 1 Get 1 on movie tickets (weekdays only)',
    icon: Icons.local_movies_rounded,
    coins: 300,
    colors: [Color(0xFFAB47BC), Color(0xFF6A1B9A)],
  ),
];

// ─── HomeScreen ───────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _pageController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ledger = ref.watch(ledgerProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Partner Deals',
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

          // ── Compact landscape carousel ────────────────────────────────────
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _deals.length,
              itemBuilder: (_, i) => _DealCard(deal: _deals[i]),
            ),
          ),

          // ── Page dots ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _deals.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: colorScheme.primary,
                  dotColor: colorScheme.primaryContainer,
                  dotHeight: 6,
                  dotWidth: 6,
                  expansionFactor: 3,
                ),
              ),
            ),
          ),

          // ── Wallet strip + pickup card ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!ledger.isLoading) _WalletStrip(ledger: ledger),
                const SizedBox(height: 14),
                const _PickupCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Deal card (landscape split layout) ──────────────────────────────────────

class _DealCard extends StatelessWidget {
  final _Deal deal;
  const _DealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: deal.colors[0].withAlpha(65),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Left: brand identity panel
            Container(
              width: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: deal.colors,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(deal.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      deal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          '${deal.coins} coins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right: offer details panel
            Expanded(
              child: Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: deal.colors[0].withAlpha(22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PARTNER OFFER',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: deal.colors[0],
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      deal.tagline,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal.offer,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(155),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 30,
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: deal.colors[1],
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Claim',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
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

// ─── Wallet summary strip ─────────────────────────────────────────────────────

class _WalletStrip extends StatelessWidget {
  final LedgerState ledger;
  const _WalletStrip({required this.ledger});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.stars_rounded, color: colorScheme.secondary, size: 26),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ledger.availableCoins}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'My Balance',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(120),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.group_rounded, color: colorScheme.primary, size: 26),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ledger.colonyTotalCoins}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Colony Total',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(140),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Pickup schedule card ─────────────────────────────────────────────────────

class _PickupCard extends StatelessWidget {
  const _PickupCard();

  static bool _isDry(int day) => day.isOdd && day <= 5;
  static const _labels = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  String _nextPickup(int today) {
    if (today >= 6) return 'Monday, 7:30 AM · Dry waste';
    final next = today + 1;
    return 'Tomorrow, 7:30 AM · ${_isDry(next) ? "Dry" : "Wet"} waste';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final today = DateTime.now().weekday;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.delete_sweep_outlined, color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Waste Pickup Schedule',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Next: ${_nextPickup(today)}',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                final day = i + 1;
                final isDry = _isDry(day);
                final isToday = day == today;
                final chipColor = isDry ? colorScheme.primary : Colors.blue.shade400;

                return Column(
                  children: [
                    Text(
                      _labels[day],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isToday
                            ? colorScheme.primary
                            : colorScheme.onSurface.withAlpha(120),
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isToday ? chipColor : chipColor.withAlpha(35),
                        borderRadius: BorderRadius.circular(12),
                        border: isToday
                            ? Border.all(color: chipColor, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isDry ? 'D' : 'W',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isToday ? Colors.white : chipColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Legend(color: colorScheme.primary, label: 'Dry Waste'),
                const SizedBox(width: 20),
                _Legend(color: Colors.blue.shade400, label: 'Wet Waste'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

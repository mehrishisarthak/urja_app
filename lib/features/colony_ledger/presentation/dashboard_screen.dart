import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../notifiers/colony_ledger_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the Ledger State
    final ledgerState = ref.watch(ledgerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Urja Wallet'),
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // The ultimate architecture test:
              // Calling this automatically flips the FSM to unauthenticated,
              // and GoRouter will instantly throw the user back to /login!
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: ledgerState.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () async {
                // Allows the user to pull down to refresh their balance
                // We'd add a refresh method to the Notifier later
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- WALLET CARD ---
                    _buildWalletCard(context, ledgerState),
                    
                    const SizedBox(height: 32),
                    
                    // --- COLONY STATS ---
                    _buildColonyStats(context, ledgerState),

                    const SizedBox(height: 32),

                    // --- REWARDS SECTION ---
                    Text(
                      'Redeem Urja Coins',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildRewardItem(
                      context,
                      ref,
                      title: 'Maintenance Fee Discount',
                      description: 'Get 10% off your next monthly society maintenance bill.',
                      cost: 150,
                      icon: Icons.receipt_long,
                      availableCoins: ledgerState.availableCoins,
                    ),
                    const SizedBox(height: 12),
                    
                    _buildRewardItem(
                      context,
                      ref,
                      title: 'Free Parking Spot Upgrade',
                      description: 'Upgrade to a premium visitor spot for the weekend.',
                      cost: 300,
                      icon: Icons.local_parking,
                      availableCoins: ledgerState.availableCoins,
                    ),
                    const SizedBox(height: 12),
                    
                    _buildRewardItem(
                      context,
                      ref,
                      title: 'Exclusive Colony T-Shirt',
                      description: 'Show your eco-pride with our limited edition merch.',
                      cost: 500,
                      icon: Icons.checkroom,
                      availableCoins: ledgerState.availableCoins,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- HELPER: Wallet Card ---
  Widget _buildWalletCard(BuildContext context, LedgerState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer, // Adapts perfectly to your Light/Dark mode
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(50),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'AVAILABLE BALANCE',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimary.withAlpha(200),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.stars, color: colorScheme.secondary, size: 40),
              const SizedBox(width: 12),
              Text(
                '${state.availableCoins}',
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
            'Keep recycling to earn more!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: Colony Stats Row ---
  Widget _buildColonyStats(BuildContext context, LedgerState state) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Colony Total',
            value: '${state.colonyTotalCoins}',
            icon: Icons.group,
            theme: theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Lifetime Earned',
            value: '${state.colonyTotalCoins - state.userBaseBalance}',
            icon: Icons.eco,
            theme: theme,
          ),
        ),
      ],
    );
  }

  // --- HELPER: Reward List Item ---
  Widget _buildRewardItem(
    BuildContext context, 
    WidgetRef ref, {
    required String title,
    required String description,
    required int cost,
    required IconData icon,
    required int availableCoins,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canAfford = availableCoins >= cost;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.dividerColor.withAlpha(50)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.stars, color: colorScheme.secondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$cost Coins',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: canAfford ? colorScheme.primary : colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: canAfford 
                  ? () => ref.read(ledgerProvider.notifier).redeemCoins(cost)
                  : null, 
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Get'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MINI HELPER COMPONENT ---
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
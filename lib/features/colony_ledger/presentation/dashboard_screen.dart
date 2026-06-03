import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'profile_sheet.dart';
import 'rewards_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _tab = 0;

  void _openProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.account_circle_outlined, size: 28),
          tooltip: 'Profile',
          onPressed: _openProfile,
        ),
        title: Text(_tab == 0 ? 'Urja' : 'My Rewards'),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          HomeScreen(),
          RewardsScreen(),
        ],
      ),
    );
  }
}

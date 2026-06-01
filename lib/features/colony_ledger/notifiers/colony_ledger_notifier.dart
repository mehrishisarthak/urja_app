import 'package:flutter_riverpod/flutter_riverpod.dart';

class LedgerState {
  final bool isLoading;
  final String colonyId;
  final int colonyTotalCoins; // Total coins the whole colony has ever earned
  final int userBaseBalance;  // The snapshot of colonyTotalCoins when the user joined
  final int userRedeemed;     // Coins this specific user has already spent
  final String? errorMessage;

  LedgerState({
    this.isLoading = true,
    this.colonyId = '',
    this.colonyTotalCoins = 0,
    this.userBaseBalance = 0,
    this.userRedeemed = 0,
    this.errorMessage,
  });

  int get availableCoins {
    final earnedSinceJoining = colonyTotalCoins - userBaseBalance;
    final available = earnedSinceJoining - userRedeemed;
    return available > 0 ? available : 0; //no garbage values
  }

  LedgerState copyWith({
    bool? isLoading,
    String? colonyId,
    int? colonyTotalCoins,
    int? userBaseBalance,
    int? userRedeemed,
    String? errorMessage,
  }) {
    return LedgerState(
      isLoading: isLoading ?? this.isLoading,
      colonyId: colonyId ?? this.colonyId,
      colonyTotalCoins: colonyTotalCoins ?? this.colonyTotalCoins,
      userBaseBalance: userBaseBalance ?? this.userBaseBalance,
      userRedeemed: userRedeemed ?? this.userRedeemed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

//The Notifier
class ColonyLedgerNotifier extends Notifier<LedgerState> {
  @override
  LedgerState build() {
    _fetchLedgerData();
    return LedgerState();
  }

  Future<void> _fetchLedgerData() async {
    // In Phase 4, this will be:
    // 1. Get current User's document from Firestore (to get baseBalance and redeemed)
    // 2. Get Colony document from Firestore (to get colonyTotalCoins)

    // For now, we simulate a 1.5 second network call with dummy data
    await Future.delayed(const Duration(milliseconds: 1500));

    state = state.copyWith(
      isLoading: false,
      colonyId: 'URJA-JPR-444435',
      colonyTotalCoins: 1250,   // The whole colony has 1250 coins
      userBaseBalance: 1000,    // But it was at 1000 when this user joined (They earned 250)
      userRedeemed: 50,         // And this user already spent 50 coins
    );
  }

  Future<void> redeemCoins(int cost) async {
    
    if (state.availableCoins < cost) return;

    state = state.copyWith(isLoading: true);

    // Simulate sending the redemption to the backend
    await Future.delayed(const Duration(seconds: 1));

    // Update the local state so the UI reflects the new balance instantly
    state = state.copyWith(
      isLoading: false,
      userRedeemed: state.userRedeemed + cost,
    );
  }
}

// 3. The Global Provider
final ledgerProvider = NotifierProvider<ColonyLedgerNotifier, LedgerState>(() {
  return ColonyLedgerNotifier();
});
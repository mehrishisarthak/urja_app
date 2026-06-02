import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:urja/features/authentication/providers/user_profile_provider.dart'; 

// 1. THE STATE MODEL (Unchanged)
class LedgerState {
  final bool isLoading;
  final String colonyId;
  final int colonyTotalCoins; 
  final int userBaseBalance;  
  final int userRedeemed;     
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
    return available > 0 ? available : 0; 
  }
}

// 2. THE LIVE COLONY STREAM (The Read Pipe 1)
final liveColonyTotalProvider = StreamProvider<int>((ref) {
  // Grab the user's profile from the stream we already built
  final profile = ref.watch(userProfileProvider).value;
  
  if (profile == null || profile.colonyId == null) {
    return Stream.value(0); // Failsafe
  }

  // Open a live pipe to the specific colony document
  return FirebaseFirestore.instance
      .collection('colonies')
      .doc(profile.colonyId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return 0;
        final data = doc.data() as Map<String, dynamic>;
        // Use ?? 0 to prevent null crashes
        return data['totalCoinsEarned'] as int? ?? 0;
      });
});

// 3. THE MATH ENGINE (The Combiner)
final ledgerProvider = Provider<LedgerState>((ref) {
  // Watch both live streams
  final profileState = ref.watch(userProfileProvider);
  final colonyTotalState = ref.watch(liveColonyTotalProvider);

  // If either stream is still fetching from the cloud, show loading
  if (profileState.isLoading || colonyTotalState.isLoading) {
    return LedgerState(isLoading: true);
  }

  final profile = profileState.value;
  final colonyTotal = colonyTotalState.value ?? 0;

  if (profile == null) {
    return LedgerState(errorMessage: "No profile found");
  }

  // Do the math automatically every time Firestore pushes an update!
  return LedgerState(
    isLoading: false,
    colonyId: profile.colonyId ?? '',
    colonyTotalCoins: colonyTotal,
    userBaseBalance: profile.baseBalanceAtJoin,
    userRedeemed: profile.coinsRedeemed,
  );
});

class RedemptionController extends Notifier<bool> {
  @override
  bool build() => false; // false = not currently loading

  Future<void> redeemCoins(int cost, int availableCoins) async {
    // 1. Guard checks
    if (availableCoins < cost || state == true) return;

    // 2. Set loading state to true
    state = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final db = FirebaseFirestore.instance;
      await db.collection('users').doc(user.uid).update({
        'coinsRedeemed': FieldValue.increment(cost),
      });

    } catch (e) {
      print("Redemption Error: $e");
    } finally {
      // 4. Turn off loading state
      state = false;
    }
  }
}

final redemptionProvider = NotifierProvider<RedemptionController, bool>(() {
  return RedemptionController();
});
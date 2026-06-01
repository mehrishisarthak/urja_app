import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ColonySetupState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ColonySetupState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });
}

class ColonySetupNotifier extends Notifier<ColonySetupState> {
  @override
  ColonySetupState build() {
    return ColonySetupState();
  }

  Future<void> joinColony(String code) async {
    if (code.isEmpty) {
      state = ColonySetupState(errorMessage: "Please enter a code.");
      return;
    }

    state = ColonySetupState(isLoading: true);

    try {
      final db = FirebaseFirestore.instance;
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) throw Exception("User not logged in");

      // 1. Verify the Colony exists
      final colonyDoc = await db.collection('colonies').doc(code).get();
      
      if (!colonyDoc.exists) {
        throw Exception("Colony code not found. Please try again.");
      }

      // 2. Get Colony's current stats
      final colonyData = colonyDoc.data() as Map<String, dynamic>;
      final currentTotal = colonyData['totalCoinsEarned'] ?? 0;

      // 3. Update the User's document
      await db.collection('users').doc(userId).set({
        'colonyId': code,
        'baseBalanceAtJoin': currentTotal,
        'coinsRedeemed': 0,
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Success! (The FSM will catch this and route to dashboard)
      state = ColonySetupState(isLoading: false, isSuccess: true);

    } catch (e) {
      state = ColonySetupState(isLoading: false, errorMessage: e.toString());
    }
  }
}

final colonySetupProvider = NotifierProvider<ColonySetupNotifier, ColonySetupState>(() {
  return ColonySetupNotifier();
});
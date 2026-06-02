import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urja/features/authentication/notifiers/auth_notifier.dart';

class UserProfile {
  final String? colonyId;
  final int coinsRedeemed;
  final int baseBalanceAtJoin;

  UserProfile({this.colonyId, this.coinsRedeemed = 0, this.baseBalanceAtJoin = 0});

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) return UserProfile();
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      colonyId: data['colonyId'] as String?,
      coinsRedeemed: data['coinsRedeemed'] ?? 0,
      baseBalanceAtJoin: data['baseBalanceAtJoin'] ?? 0,
    );
  }
}

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value(null); 
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => UserProfile.fromFirestore(doc));
});
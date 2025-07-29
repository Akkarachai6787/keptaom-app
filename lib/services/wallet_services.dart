import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keptaom/models/wallet.dart';

class WalletServices {
  Future<List<Wallet>> fetchWallets() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('wallets')
        .get();
    final data = snapshot.docs.map((doc) => Wallet.fromFirestore(doc)).toList();
    return data;
  }

  Future<void> addWallet(String name, double balance) async {
    await FirebaseFirestore.instance.collection('wallets').add({
      'name': name,
      'balance': balance,
    });
  }

  Future<void> updateWallet(String id, String name, double balance) async {
    await FirebaseFirestore.instance.collection('wallets').doc(id).update({
      'name': name,
      'balance': balance,
    });
  }

  Future<void> deleteWallet(String walletId) async {
    await FirebaseFirestore.instance
        .collection('wallets')
        .doc(walletId)
        .delete();
  }

  Future<void> updateWalletBalance({
    required String walletId,
    required double amountChange,
    required bool isIncome,
  }) async {
    final walletRef = FirebaseFirestore.instance
        .collection('wallets')
        .doc(walletId);

    final snapshot = await walletRef.get();
    final data = snapshot.data();

    if (data == null || !data.containsKey('balance')) {
      throw Exception('Wallet not found or missing balance field');
    }

    final currentBalance = (data['balance'] ?? 0).toDouble();
    double newBalance = isIncome
        ? currentBalance + amountChange
        : currentBalance - amountChange;

    newBalance = (newBalance * 100).round() / 100;

    await walletRef.update({'balance': newBalance});
  }

  Future<void> reverseWalletBalanceChange({
    required String walletId,
    required double amountChange,
    required bool isIncome,
  }) async {
    final walletRef = FirebaseFirestore.instance
        .collection('wallets')
        .doc(walletId);

    final snapshot = await walletRef.get();
    final data = snapshot.data();

    if (data == null || !data.containsKey('balance')) {
      throw Exception('Wallet not found or missing balance field');
    }

    final currentBalance = (data['balance'] ?? 0).toDouble();
    double newBalance = isIncome
        ? currentBalance - amountChange
        : currentBalance + amountChange;

    newBalance = (newBalance * 100).round() / 100;

    await walletRef.update({'balance': newBalance});
  }
}

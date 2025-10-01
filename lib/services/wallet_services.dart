import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:keptaom/models/wallet.dart';

class WalletServices {
  Future<List<Wallet>> fetchWallets(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('wallets')
        .where('userId', isEqualTo: uid)
        .get();
    final data = snapshot.docs.map((doc) => Wallet.fromFirestore(doc)).toList();

    data.sort((a, b) => b.date.compareTo(a.date));
    return data;
  }

  Future<Wallet?> fetchWalletById(String wid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('wallets')
          .doc(wid)
          .get();

      if (doc.exists) {
        return Wallet.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching wallet by id: $e");
      return null;
    }
  }

  Future<void> addWallet({
    required String name,
    required double balance,
    required String userId,
  }) async {
    await FirebaseFirestore.instance.collection('wallets').add({
      'name': name,
      'balance': balance,
      'user': FirebaseFirestore.instance.collection('users').doc(userId),
      'userId': userId,
      'createdAt': DateTime.now(),
      'date': DateTime.now(),
    });
  }

  Future<void> updateWallet({
    required String id,
    required String name,
    required double balance,
  }) async {
    await FirebaseFirestore.instance.collection('wallets').doc(id).update({
      'name': name,
      'balance': balance,
      'date': DateTime.now(),
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

    await walletRef.update({'balance': newBalance, 'date': DateTime.now()});
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

    await walletRef.update({'balance': newBalance, 'date': DateTime.now()});
  }
}

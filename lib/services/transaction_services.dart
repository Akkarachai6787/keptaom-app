import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keptaom/models/transaction.dart';

class TransactionPageResult {
  final List<TransactionModel> transactions;
  final String? lastId;

  TransactionPageResult({required this.transactions, this.lastId});
}

class Transactionservices {
  Future<List<TransactionModel>> fetchLastestTransactions({
    required String uid,
    int limit = 20,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .get();

    final transactions = snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();

    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return transactions.take(limit).toList();
  }

  Future<TransactionPageResult> fetchAllTransactions({
    required String uid,
    int limit = 20,
    String? lastId,
    required int month,
    required int year,
  }) async {
    final collection = FirebaseFirestore.instance.collection('transactions');

    final yearMonth =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

    try {
      final snapshot = await collection
          .where('userId', isEqualTo: uid)
          .where('yearMonth', isEqualTo: yearMonth)
          .get();

      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      int startIndex = 0;
      if (lastId != null) {
        final idx = transactions.indexWhere((t) => t.id == lastId);
        startIndex = idx >= 0 ? idx + 1 : 0;
      }

      final pageTransactions = transactions
          .skip(startIndex)
          .take(limit)
          .toList();
      final newLastId = pageTransactions.isNotEmpty
          ? pageTransactions.last.id
          : null;

      return TransactionPageResult(
        transactions: pageTransactions,
        lastId: newLastId,
      );
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      rethrow;
    }
  }

  Future<Map<String, List<TransactionModel>>> getTransactionsForAnalyze({
    required String userId,
    required int month,
    required int year,
  }) async {
    final yearMonth =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        // .where('isTransfer', isEqualTo: false)
        .where('yearMonth', isEqualTo: yearMonth)
        .get();

    final transactions = snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();

    final forAnalyze = transactions
        .where((t) => t.isTransfer == false)
        .toList();
    final otherLists = transactions
        .where((t) => t.typeId == 'transfer' || t.typeId == 'budget')
        .toList();

    return {'forAnalyze': forAnalyze, 'otherLists': otherLists};
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required DateTime date,
    required bool isTransfer,
    required bool isIncome,
    required String walletId,
    required String userId,
    String? typeId,
    String? toWalletId,
  }) async {
    final data = {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'yearMonth':
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}',
      'isTransfer': isTransfer,
      'isIncome': isIncome,
      'wallet': FirebaseFirestore.instance.collection('wallets').doc(walletId),
      'walletId': walletId,
      'user': FirebaseFirestore.instance.collection('users').doc(userId),
      'userId': userId,
    };

    if (typeId != null) {
      data['type'] = FirebaseFirestore.instance.collection('types').doc(typeId);
      data['typeId'] = typeId;
    }

    if (toWalletId != null) {
      data['toWalletId'] = toWalletId;
    }

    await FirebaseFirestore.instance.collection('transactions').add(data);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  Future<void> deleteTransactionsByWalletId(String walletId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('walletId', isEqualTo: walletId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Future<void> addField(String userId) async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('transactions')
  //       .where('userId', isEqualTo: userId)
  //       .get();

  //   WriteBatch batch = FirebaseFirestore.instance.batch();

  //   for (var doc in snapshot.docs) {
  //     batch.update(doc.reference, {
  //       'toWalletId': null,
  //     });
  //   }

  //   await batch.commit();
  // }

  // Future<void> deleteTransactionsByType(String typeId) async {
  //   try {
  //     // Query all transactions with the given typeId
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('transactions')
  //         .where('typeId', isEqualTo: typeId)
  //         .get();

  //     // Use a batch to delete all at once
  //     WriteBatch batch = FirebaseFirestore.instance.batch();

  //     for (var doc in querySnapshot.docs) {
  //       batch.delete(doc.reference);
  //     }

  //     await batch.commit();
  //     print(
  //       "Deleted ${querySnapshot.docs.length} transactions with typeId = $typeId",
  //     );
  //   } catch (e) {
  //     print("Error deleting transactions: $e");
  //     rethrow;
  //   }
  // }
}

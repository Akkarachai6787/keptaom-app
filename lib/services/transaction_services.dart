import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keptaom/models/transaction.dart';

class Transactionservices {
  Future<List<TransactionModel>> fetchTransactions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required DateTime date,
    required bool isIncome,
    required String walletId,
    required String typeId,
  }) async {
    await FirebaseFirestore.instance.collection('transactions').add({
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'isIncome': isIncome,
      'wallet': FirebaseFirestore.instance.collection('wallets').doc(walletId),
      'type': FirebaseFirestore.instance.collection('types').doc(typeId),
    });
  }

  Future<void> deleteTransaction(String transactionId) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }
}

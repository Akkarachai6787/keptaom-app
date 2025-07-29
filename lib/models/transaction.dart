import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final Timestamp date;
  final bool isIncome;
  final DocumentReference? type; // <-- ทำให้เป็น nullable
  final DocumentReference? wallet; // <-- ทำให้เป็น nullable

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.type,
    this.wallet,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] is num)
          ? (data['amount'] as num).toDouble()
          : 0.0,
      date: data['date'] ?? Timestamp.now(),
      isIncome: data['isIncome'] ?? true,
      type: data['type'] is DocumentReference
          ? data['type'] as DocumentReference
          : null,
      wallet: data['wallet'] is DocumentReference
          ? data['wallet'] as DocumentReference
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
      'isIncome': isIncome,
      'type': type,
      'wallet': wallet,
    };
  }
}

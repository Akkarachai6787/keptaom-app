import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final Timestamp date;
  final bool isIncome;
  final DocumentReference? type;
  final String typeId;
  final DocumentReference? wallet;
  final String walletId;
  DateTime get dateTime => date.toDate();

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.type,
    required this.typeId,
    this.wallet,
    required this.walletId,
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
      typeId: data['typeId'] ?? '',
      wallet: data['wallet'] is DocumentReference
          ? data['wallet'] as DocumentReference
          : null,
      walletId: data['walletId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
      'isIncome': isIncome,
      'type': type,
      'typeId': typeId,
      'wallet': wallet,
      'walletId': walletId,
    };
  }
}

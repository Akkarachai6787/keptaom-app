import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String id;
  final String title;
  final double amount;
  final Timestamp date;
  final String yearMonth;
  final bool isTransfer;
  final String? toWalletId;
  final DocumentReference? type;
  final String typeId;
  final bool isPaid;
  final String? walletId;
  final DocumentReference? uid;
  final String uidId;
  final bool repeatEnabled;
  final String? repeatFrequency;
  final int? repeatInterval;
  final Timestamp? repeatEndDate;
  final Timestamp? nextBillDate;

  Bill({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.yearMonth,
    required this.isTransfer,
    this.toWalletId,
    this.type,
    required this.typeId,
    required this.isPaid,
    this.walletId,
    this.uid,
    required this.uidId,
    required this.repeatEnabled,
    this.repeatFrequency,
    this.repeatInterval,
    this.repeatEndDate,
    this.nextBillDate,
  });

  factory Bill.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Bill(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] is num)
          ? (data['amount'] as num).toDouble()
          : 0.0,
      date: data['date'] ?? Timestamp.now(),
      yearMonth: data['yearMonth'] ?? '',
      isTransfer: data['isTransfer'] ?? false,
      toWalletId: data['toWalletId'],
      type: data['type'],
      typeId: data['typeId'],
      isPaid: data['isPaid'] ?? false,
      walletId: data['walletId'] ?? '',
      uid: data['user'],
      uidId: data['userId'],
      repeatEnabled: data['repeat']?['enabled'] ?? false,
      repeatFrequency: data['repeat']?['frequency'],
      repeatInterval: data['repeat']?['interval'],
      repeatEndDate: data['repeat']?['endDate'],
      nextBillDate: data['repeat']?['nextBill'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
      'yearMonth': yearMonth,
      'isTransfer': isTransfer,
      'toWalletId': toWalletId,
      'type': type,
      'typeId': typeId,
      'isPaid': isPaid,
      'wallet': walletId,
      'user': uid,
      'userId': uidId,
      'repeat': {
        'enabled': repeatEnabled,
        'frequency': repeatFrequency,
        'interval': repeatInterval,
        'endDate': repeatEndDate,
        'nextBill': nextBillDate,
      },
    };
  }
}

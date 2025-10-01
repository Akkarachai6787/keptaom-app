import 'package:cloud_firestore/cloud_firestore.dart';

class Wallet {
  final String id;
  final String label;
  final Timestamp date;
  final Timestamp createdAt;
  final double amount;
  final DocumentReference? uid;
  final String uidId;

  Wallet({
    required this.id,
    required this.label,
    required this.date,
    required this.createdAt,
    required this.amount,
    this.uid,
    required this.uidId,
  });

  factory Wallet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Wallet(
      id: doc.id,
      label: data['name'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      amount: (data['balance'] is num)
          ? (data['balance'] as num).toDouble()
          : 0.0,
      uid: data['uid'] is DocumentReference
      ? data['uid'] as DocumentReference
      : null,
      uidId: data['uiId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': label,     
      'date' : date,
      'createdAt': createdAt,
      'balance': amount, 
      'uid' : uid,
      'uidId' : uidId,
    };
  }
}
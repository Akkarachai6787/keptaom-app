import 'package:cloud_firestore/cloud_firestore.dart';

class Wallet {
  final String id;
  final String label;
  final double amount;

  Wallet({
    required this.id,
    required this.label,
    required this.amount,
  });

  factory Wallet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Wallet(
      id: doc.id,
      label: data['name'] ?? '',
      amount: (data['balance'] is num)
          ? (data['balance'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': label,      
      'balance': amount,  
    };
  }
}
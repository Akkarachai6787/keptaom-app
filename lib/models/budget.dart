import 'package:cloud_firestore/cloud_firestore.dart';

class MonthRecord {
  final double recommended;
  final bool finalized;

  MonthRecord({required this.recommended, required this.finalized});

  factory MonthRecord.fromMap(Map<String, dynamic> data) {
    return MonthRecord(
      recommended: (data['recommended'] is num)
          ? (data['recommended'] as num).toDouble()
          : 0.0,
      finalized: data['finalized'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {'recommended': recommended, 'finalized': finalized};
  }
}

class Budget {
  final String id;
  final String label;
  final Timestamp date;
  final Timestamp createdAt;
  final double amount;
  final DocumentReference? uid;
  final String uidId;
  final Map<String, MonthRecord> monthsAdded;

  Budget({
    required this.id,
    required this.label,
    required this.date,
    required this.createdAt,
    required this.amount,
    this.uid,
    required this.uidId,
    required this.monthsAdded,
  });

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Budget(
      id: doc.id,
      label: data['label'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      amount: (data['amount'] is num)
          ? (data['amount'] as num).toDouble()
          : 0.0,
      uid: data['uid'] is DocumentReference
          ? data['uid'] as DocumentReference
          : null,
      uidId: data['uiId'] ?? '',
      monthsAdded:
          (data['monthsAdded'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, MonthRecord.fromMap(value)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'date': date,
      'createdAt': createdAt,
      'amount': amount,
      'uid': uid,
      'uidId': uidId,
      'monthsAdded': monthsAdded.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }
}

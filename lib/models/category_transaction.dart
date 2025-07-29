import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryTransaction {
  final String id;
  final String title;
  final bool isIncome;
  final String color;

  CategoryTransaction({
    required this.id,
    required this.title,
    required this.isIncome,
    required this.color,
  });

  factory CategoryTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CategoryTransaction(
      id: doc.id,
      title: data['title'] ?? '',
      isIncome: data['isIncome'] ?? true,
      color: data['color'] ?? '#ffffff',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'isIncome': isIncome, 'color': color};
  }
}

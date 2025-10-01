import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/budget.dart';

class BudgetServices {
  final CollectionReference _budgetRef = FirebaseFirestore.instance.collection(
    'budgets',
  );

  Future<List<Budget>> fetchBudgets(String uid) async {
    final snapshot = await _budgetRef.where('userId', isEqualTo: uid).get();

    final data = snapshot.docs.map((doc) => Budget.fromFirestore(doc)).toList();

    data.sort((a, b) => b.date.compareTo(a.date));
    return data;
  }

  Future<Budget?> getBudgetById(String budgetId) async {
    try {
      final doc = await _budgetRef.doc(budgetId).get();

      if (doc.exists) {
        return Budget.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching budget by id: $e");
      return null;
    }
  }

  Future<void> addBudget({
    required String label,
    required String uidId,
  }) async {
    await _budgetRef.add({
      'label': label,
      'amount': 0.0,
      'user': FirebaseFirestore.instance.collection('users').doc(uidId),
      'userId': uidId,
      'createdAt': DateTime.now(),
      'date': DateTime.now(),
      'monthsAdded': {}
    });
  }

  Future<void> updateBudgetBalance({
    required String id,
    required double amount,
    required bool isIncome,
    double currentAmount = 0.0,
    // required String fromWalletId,
    }) async {

    double newAmount = isIncome ? currentAmount + amount : currentAmount - amount;
    await _budgetRef.doc(id).update({
    'amount': newAmount,          
    // 'contributions.$fromWalletId': FieldValue.increment(amount),
    'updatedAt': DateTime.now(),
    });
  }

  Future<void> startOfMonthBudget(String budgetId) async {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final docRef = _budgetRef.doc(budgetId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final monthsAdded = data['monthsAdded'] as Map<String, dynamic>? ?? {};

    if (!monthsAdded.containsKey(key)) {
      monthsAdded[key] = {
        'recommended': 0.0,
        'finalized': false,
      };

      await docRef.update({'monthsAdded': monthsAdded});
    }
  }

  Future<void> endOfMonthBudget(String budgetId, double actual) async {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final docRef = _budgetRef.doc(budgetId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final monthsAdded = data['monthsAdded'] as Map<String, dynamic>? ?? {};

    if (monthsAdded.containsKey(key)) {
      monthsAdded[key] = {
        'recommended': actual,
        'finalized': true,
      };

      await docRef.update({'monthsAdded': monthsAdded});
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    await _budgetRef.doc(budgetId).delete();
  }
}

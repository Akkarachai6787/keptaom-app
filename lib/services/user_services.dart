import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

const defaultTypeIds = [
  'income',
  'bill',
  'budget',
  'otherExpense',
  'otherIncome',
  'transfer',
  'expense',
];

class UserServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTypeToUser(String userId, String typeId) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await docRef.set({
      'types': {typeId: true},
    }, SetOptions(merge: true));
  }

  Future<void> addTypesToUser(String userId) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final Map<String, dynamic> typesMap = {
      for (var id in defaultTypeIds) id: true,
    };

    await docRef.set({'types': typesMap}, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      return null;
    }
  }

  Future<void> updateEnableBudget({
    required String userId,
    required bool enable,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'enableBudget': enable,
      'updatedAt': DateTime.now(),
    });
  }
}

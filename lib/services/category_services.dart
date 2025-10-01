import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keptaom/models/category_transaction.dart';

class CategoryServices {
  Future<List<CategoryTransaction>> fetchCategories(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) return [];

    final userData = userDoc.data();

    if (userData == null || userData['types'] == null) return [];

    final Map<String, dynamic> typesMap = Map<String, dynamic>.from(
      userData['types'],
    );
    final List<String> typeIds = typesMap.keys.toList();

    if (typeIds.isEmpty) return [];

    final snapshot = await FirebaseFirestore.instance.collection('types').get();

    final data = snapshot.docs
        .where((doc) => typeIds.contains(doc.id))
        .map((doc) => CategoryTransaction.fromFirestore(doc))
        .toList();

    return data;
  }

  Future<CategoryTransaction?> fetchCategoryById(String typeId) async {
    final doc = await FirebaseFirestore.instance
        .collection('types')
        .doc(typeId)
        .get();

    if (!doc.exists) return null;

    return CategoryTransaction.fromFirestore(doc);
  }

  Future<List<CategoryTransaction>> fetchCategoriesIsIncome(
    bool isIncome,
    String userId,
  ) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) return [];

    final userData = userDoc.data();

    if (userData == null || userData['types'] == null) return [];

    final Map<String, dynamic> typesMap = Map<String, dynamic>.from(
      userData['types'],
    );
    final List<String> typeIds = typesMap.keys.toList();

    if (typeIds.isEmpty) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('types')
        .where('isIncome', isEqualTo: isIncome)
        .get();

    final data = snapshot.docs
        .where((doc) => typeIds.contains(doc.id))
        .map((doc) => CategoryTransaction.fromFirestore(doc))
        .toList();

    return data;
  }

  Future<String> addCategory({
    required String title,
    required bool isIncome,
    required String colorHex,
  }) async {
     final docRef = await FirebaseFirestore.instance.collection('types').add({
      'title': title,
      'isIncome': isIncome,
      'color': colorHex,
    });

    return docRef.id;
  }

}

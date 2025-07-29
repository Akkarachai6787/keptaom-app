import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keptaom/models/category_transaction.dart';

class CategoryServices {
  Future<List<CategoryTransaction>> fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('types').get();
    final data = snapshot.docs
        .map((doc) => CategoryTransaction.fromFirestore(doc))
        .toList();
    return data;
  }
  
  Future<CategoryTransaction?> fetchCategoryById(String typeId) async {
  final doc = await FirebaseFirestore.instance.collection('types').doc(typeId).get();
  if (!doc.exists) return null;
  return CategoryTransaction.fromFirestore(doc);
}


  Future<List<CategoryTransaction>> fetchCategoriesIsIncome(bool isIncome) async {
    final snapshot = await FirebaseFirestore.instance.collection('types').where('isIncome', isEqualTo: isIncome).get();
    final data = snapshot.docs
        .map((doc) => CategoryTransaction.fromFirestore(doc))
        .toList();
    return data;
  }
}

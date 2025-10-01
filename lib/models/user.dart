import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final Timestamp updatedAt;
  final Timestamp createdAt;
  final bool enableBudget;
  final String uid;
  final Map<String, bool> types;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.updatedAt,
    required this.createdAt,
    required this.enableBudget,
    required this.uid,
    required this.types,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      updatedAt: data['updateAt'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      enableBudget: data['enableBudget'] ?? false,
      uid: data['uid'] ?? '',
      types:
          (data['types'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, true),
          ) ??
          {},
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      updatedAt: data['updateAt'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      enableBudget: data['enableBudget'] ?? false,
      uid: data['uid'] ?? '',
      types:
          (data['types'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, true),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'updateAt': updatedAt,
      'createdAt': createdAt,
      'enableBudget': enableBudget,
      'uid': uid,
      'types': types.map((key, value) => MapEntry(key, true)),
    };
  }
}

import 'package:flutter/material.dart';
import 'package:keptaom/models/category_transaction.dart';
// import 'package:keptaom/models/wallet.dart';
import '../models/list_combined.dart';

class DropdownTypesSelectorSheet extends StatelessWidget {
  final List<CategoryTransaction> docs;
  final String Function(CategoryTransaction) fieldGetter;

  const DropdownTypesSelectorSheet({
    super.key,
    required this.docs,
    required this.fieldGetter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF202020),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: docs.length,
        separatorBuilder: (_, __) => const Divider(color: Color(0xFF858585)),
        itemBuilder: (context, index) {
          final doc = docs[index];
          return ListTile(
            title: Text(
              fieldGetter(doc),
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context, doc.id),
          );
        },
      ),
    );
  }
}

class DropdownWalletsSelectorSheet extends StatelessWidget {
  final List<ListCombined> docs;
  final String Function(ListCombined) fieldGetter;

  const DropdownWalletsSelectorSheet({
    super.key,
    required this.docs,
    required this.fieldGetter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF202020),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: docs.length,
        separatorBuilder: (_, __) => const Divider(color: Color(0xFF858585)),
        itemBuilder: (context, index) {
          final doc = docs[index];
          return ListTile(
            title: Text(
              fieldGetter(doc),
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context, doc.id),
          );
        },
      ),
    );
  }
}

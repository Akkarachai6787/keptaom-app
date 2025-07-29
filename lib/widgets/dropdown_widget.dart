import 'package:flutter/material.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/models/wallet.dart';

class DropdownTypesSelectorSheet extends StatelessWidget {
  final List<CategoryTransaction> docs;
  final String Function(CategoryTransaction) fieldGetter;

  const DropdownTypesSelectorSheet({
    Key? key,
    required this.docs,
    required this.fieldGetter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1e293b),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: docs.length,
        separatorBuilder: (_, __) => const Divider(color: Color(0xFF4b5563)),
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
  final List<Wallet> docs;
  final String Function(Wallet) fieldGetter;

  const DropdownWalletsSelectorSheet({
    Key? key,
    required this.docs,
    required this.fieldGetter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1e293b),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: docs.length,
        separatorBuilder: (_, __) => const Divider(color: Color(0xFF4b5563)),
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

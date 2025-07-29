import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keptaom/models/transaction.dart';
import '../screens/transaction_info_screen.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final Future<void> Function()? onUpdate;

  const TransactionItem({super.key, required this.transaction, this.onUpdate});

  @override
  Widget build(BuildContext context) {
    // final isIncome = transaction.amount >= 0;

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionInfoScreen(transaction: transaction),
          ),
        );

        if (result == true && onUpdate != null) {
          await onUpdate!();
        }
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1f2937),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            top: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
            bottom: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
            left: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
            right: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.date),
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            Text(
              '฿ ${NumberFormat("#,##0.00", "en_US").format(transaction.amount.abs())}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: transaction.isIncome ? Colors.teal[500] : Colors.red[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate(); // Convert to DateTime
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

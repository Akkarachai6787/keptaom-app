import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/models/category_transaction.dart';
import '../screens/transaction_info_screen.dart';
import 'package:keptaom/utils/color_utils.dart';
import 'package:keptaom/utils/format_date.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryTransaction? category;
  final Future<void> Function()? onUpdate;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onUpdate,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = category != null
        ? hexToColor(category!.color)
        : Colors.white;

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionInfoScreen(transaction: transaction, catColor: catColor),
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
          color: const Color(0xFF292e31),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF292e31), width: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: catColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                transaction.isIncome
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
                    formatDate(transaction.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${transaction.isIncome ? '' : '-'}${NumberFormat("#,##0.00", "en_US").format(transaction.amount.abs())} ฿',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/utils/color_utils.dart';
import 'package:keptaom/screens/transaction_by_month.dart';

class CategoriesItem extends StatelessWidget {
  final CategoryTransaction category;
  final double totalAmount;
  final double percent;
  final List<TransactionModel> transactions;
  final String month;
  final int year;
  final VoidCallback? onRefresh;

  const CategoriesItem({
    Key? key,
    required this.category,
    required this.totalAmount,
    required this.percent,
    required this.transactions,
    required this.month,
    required this.year,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final catColor = hexToColor(category.color);

    return InkWell(
      onTap: () async {
        final shouldRefresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionByMonth(transaction: transactions, month: month, year: year, category: category),
          ),
        );

      print('check_item $shouldRefresh');
        if (shouldRefresh == true) {
          if (onRefresh != null) {
            onRefresh!();
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1f2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4b5563), width: 0.3),
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
                category.isIncome
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${category.isIncome ? '' : '-'}${NumberFormat("#,##0.00", "en_US").format(totalAmount.abs())} ฿',

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${percent.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

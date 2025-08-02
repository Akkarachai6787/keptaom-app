import 'package:flutter/material.dart';

class ExpenseProgressWidget extends StatelessWidget {
  final double expensePercent; // e.g. 72.35
  final double leftRecommended; // amount left in currency
  final bool isPositive; // true if expensePercent <= 100%

  const ExpenseProgressWidget({
    Key? key,
    required this.expensePercent,
    required this.leftRecommended,
    required this.isPositive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (expensePercent / 100).clamp(0.0, 1.0);

    final Color progressColor;
    if (expensePercent < 60) {
      progressColor = Colors.teal[600]!;
    } else if (expensePercent < 80) {
      progressColor = Colors.yellow[600]!;
    } else {
      progressColor = Colors.red[600]!;
    }

    final backgroundColor = Color(0xFF1f2937);
    final textColor = leftRecommended < 0 ? Colors.red[600]! : Colors.white;

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (expensePercent != 0.0) ...[
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween<double>(begin: 0, end: progress),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 12,
                backgroundColor: backgroundColor,
                color: progressColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            const SizedBox(height: 8),
          ],
          Text(
            leftRecommended >= 0
                ? '${expensePercent.toStringAsFixed(2)}% of your recommended budget used\n($leftRecommended ฿ remaining)'
                : "You’ve exceeded your budget\n(${leftRecommended.abs()} ฿ over)",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

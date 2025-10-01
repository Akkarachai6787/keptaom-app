import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletBalanceCard extends StatelessWidget {
  final String label;
  final double amount;
  final void Function()? onLongPress;

  const WalletBalanceCard({
    super.key,
    required this.label,
    required this.amount,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF292e31),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF292e31), width: 0.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '฿ ${NumberFormat("#,##0.00", "en_US").format(amount.abs())}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  final double amount;

  const BalanceCard({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFf2f0ef),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFf2f0ef), width: 0.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommend budget',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111111),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '฿ ${NumberFormat("#,##0.00", "en_US").format(amount.abs())}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
    );
  }
}

class WalletBudgetGoalCard extends StatelessWidget {
  final String label;
  final double amount;
  final Map<String, double> contributions;
  final void Function()? onPress;
  final bool showDetails;

  const WalletBudgetGoalCard({
    super.key,
    required this.label,
    required this.amount,
    required this.contributions,
    this.onPress,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 30),
      decoration: BoxDecoration(
        color: Color(0xFF292e31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF292e31), width: 0.3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '฿ ${NumberFormat("#,##0.00", "en_US").format(amount.abs())}',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (contributions.isNotEmpty) ...[
                IconButton(
                  onPressed: onPress,
                  icon: Icon(
                    showDetails
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ],
          ),

          if (showDetails && contributions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contributions.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(color: Colors.white)),
                      Text(
                        '฿ ${NumberFormat("#,##0.00", "en_US").format(e.value)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class AddWalletCard extends StatelessWidget {
  final void Function()? onTap;

  const AddWalletCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF2E3338),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2E3338), width: 0.3),
        ),
        child: Center(
          child: Icon(Icons.add, color: const Color(0xFF9AAABB), size: 48),
        ),
      ),
    );
  }
}

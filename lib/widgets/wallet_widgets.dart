import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// WalletBalanceCard — shows the label and amount
class WalletBalanceCard extends StatelessWidget {
  final String label;
  final double amount;
  final void Function()? onLongPress;

  const WalletBalanceCard({
    Key? key,
    required this.label,
    required this.amount,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1f2937),
          borderRadius: BorderRadius.circular(20),
          border: Border(
            top: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
            bottom: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
            left: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
            right: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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

/// AddWalletCard — displays the "+" button
class AddWalletCard extends StatelessWidget {
  final void Function()? onTap;

  const AddWalletCard({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1f2937),
          borderRadius: BorderRadius.circular(20),
          border: Border(
            top: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
            bottom: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
            left: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
            right: BorderSide(color: const Color(0xFF4b5563), width: 0.3),
          ),
        ),
        child: Center(
          child: Icon(Icons.add, color:Colors.teal[400], size: 48),
        ),
      ),
    );
  }
}

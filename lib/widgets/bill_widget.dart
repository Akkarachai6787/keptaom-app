import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillCard extends StatelessWidget {
  final String title;
  final double amount;
  final DateTime date;
  final bool isPaid;

  const BillCard({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.isPaid,
  });

  String getDaysLeft() {
    final today = DateTime.now();
    final dueDate = DateTime(date.year, date.month, date.day);
    final nowDate = DateTime(today.year, today.month, today.day);

    final diff = dueDate.difference(nowDate).inDays;

    if (isPaid) return "Paid";
    if (diff == 0) return "Due today";
    if (diff > 0) return "${diff}d left";
    if (diff < 0) return "Overdue";
    return "N/A";
  }

  Color getStatusColor() {
    if (isPaid) return const Color(0xFF00796B);
    final today = DateTime.now();
    final dueDate = DateTime(date.year, date.month, date.day);
    final nowDate = DateTime(today.year, today.month, today.day);

    final diff = dueDate.difference(nowDate).inDays;

    if (diff < 0) return const Color(0xFFD32F2F);
    if (diff == 0) return const Color(0xFFF57C00);
    return const Color(0xFF2962FF);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF292e31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF292e31), width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.event, color: getStatusColor(), size: 20),
                  const SizedBox(width: 4),
                  Text(
                    getDaysLeft(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: getStatusColor(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '฿ ${NumberFormat("#,##0.00", "en_US").format(amount.abs())}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BillCardItem extends StatelessWidget {
  final String title;
  final double amount;
  final DateTime date;
  final bool isPaid;
  final String typeId;
  final VoidCallback? onPressed;
  final VoidCallback? onMarkPaid;

  const BillCardItem({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.isPaid,
    required this.typeId,
    this.onPressed,
    this.onMarkPaid,
  });

  String getDaysLeft() {
    final today = DateTime.now();
    final diff = date.difference(today).inDays;

    if (isPaid) return "Paid";
    if (diff == 0) return "Due today";
    if (diff > 0) return "${diff}d left";
    return "Overdue";
  }

  Color getStatusColor() {
    if (isPaid) return const Color(0xFF00796B);
    final today = DateTime.now();
    final diff = date.difference(today).inDays;

    if (diff < 0) return const Color(0xFFD32F2F);
    if (diff == 0) return const Color(0xFFF57C00);
    return const Color(0xFF2962FF);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF292e31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF292e31), width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.event, color: getStatusColor(), size: 20),
                  const SizedBox(width: 4),
                  Text(
                    getDaysLeft(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: getStatusColor(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 24,
                  onPressed: () {
                    if (onPressed != null) {
                      onPressed!();
                    }
                  },
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '฿ ${NumberFormat("#,##0.00", "en_US").format(amount.abs())}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 6),

          if (!isPaid)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf2f0ef),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                    side: BorderSide(color: const Color(0xFFf2f0ef), width: 2),
                  ),
                ),
                onPressed: () {
                  if (onMarkPaid != null) {
                    onMarkPaid!();
                  }
                },
                child: Text(
                  typeId == 'budget' ? 'Add budget' : 'Mark as paid',
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

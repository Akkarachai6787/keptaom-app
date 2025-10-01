import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/utils/format_date.dart';

class TransactionByMonth extends StatefulWidget {
  final List<TransactionModel> transaction;
  final String month;
  final int year;
  final CategoryTransaction category;

  const TransactionByMonth({
    super.key,
    required this.transaction,
    required this.month,
    required this.year,
    required this.category,
  });

  @override
  State<TransactionByMonth> createState() => _TransactionByMonthState();
}

class _TransactionByMonthState extends State<TransactionByMonth> {
  late List<TransactionModel> _transactions;
  bool? shouldRefresh = false;

  @override
  void initState() {
    super.initState();
    _transactions = [...widget.transaction];
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF202020),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '${widget.category.title} - ${widget.month} ${widget.year}',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 6, right: 16, bottom: 0),
        child: ListView.builder(
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final tx = _transactions[index];

            BorderRadius borderRadius;
            if (_transactions.length == 1) {
              borderRadius = BorderRadius.circular(20);
            } else if (index == 0) {
              borderRadius = const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              );
            } else if (index == _transactions.length - 1) {
              borderRadius = const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              );
            } else {
              borderRadius = BorderRadius.zero;
            }

            BoxDecoration decoration = BoxDecoration(
              color: const Color(0xFF292e31),
              borderRadius: borderRadius,
              border: index != _transactions.length - 1
                  ? const Border(
                      bottom: BorderSide(color: Color(0xFF66737A), width: 0.3),
                    )
                  : null,
            );
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: decoration,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(tx.date),
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
                    '${tx.isIncome ? '' : '-'}${NumberFormat("#,##0.00", "en_US").format(tx.amount.abs())} ฿',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

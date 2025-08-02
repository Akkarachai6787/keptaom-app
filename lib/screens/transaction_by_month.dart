import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/utils/format_date.dart';
import 'package:keptaom/screens/transaction_info_screen.dart';
import 'package:keptaom/utils/color_utils.dart';

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

  Future<void> _showBackDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Updated',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Your total net has been updated.',
            style: TextStyle(fontSize: 15, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic resultSetter) async {
        if (!didPop) {
          if (shouldRefresh == true) {
            await _showBackDialog(context);
            if (!context.mounted) return;
            Navigator.pop(context, true);
          } else {
            if (!context.mounted) return;
            Navigator.pop(context, false);
          }
        }
      },

      child: Scaffold(
        backgroundColor: const Color(0xFF111827),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111827),
          title: Text(
            '${widget.category.title} - ${widget.month} ${widget.year}',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (shouldRefresh == true) {
                await _showBackDialog(context);
                if (!context.mounted) return;
                Navigator.pop(context, true);
              } else {
                if (!context.mounted) return;
                Navigator.pop(context, false);
              }
            },
          ),
        ),
        body: ListView.builder(
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final tx = _transactions[index];
            return GestureDetector(
              onTap: () async {
                shouldRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionInfoScreen(
                      transaction: tx,
                      catColor: hexToColor(widget.category.color),
                    ),
                  ),
                );
                if (shouldRefresh == true) {
                  setState(() {
                    _transactions.removeAt(index);
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1f2937),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4b5563),
                    width: 0.3,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: tx.isIncome ? Colors.teal[600] : Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/services/transaction_services.dart';
import 'package:keptaom/services/wallet_services.dart';
import 'package:keptaom/utils/format_date.dart';

class TransactionInfoScreen extends StatefulWidget {
  final TransactionModel transaction;
  final Color catColor;

  const TransactionInfoScreen({
    super.key,
    required this.transaction,
    required this.catColor,
  });

  @override
  State<TransactionInfoScreen> createState() => _TransactionInfoScreenState();
}

class _TransactionInfoScreenState extends State<TransactionInfoScreen> {
  String? typeName;
  Color? catColor;
  String? walletName;
  String? walletId;
  bool isLoading = true;
  final transactionservices = Transactionservices();
  final walletServices = WalletServices();

  @override
  void initState() {
    super.initState();
    fetchTypeAndWalletNames();
  }

  Future<void> fetchTypeAndWalletNames() async {
    try {
      if (widget.transaction.type != null) {
        final typeSnap = await widget.transaction.type!.get();
        typeName = typeSnap.get('title');
      }

      if (widget.transaction.wallet != null) {
        final walletSnap = await widget.transaction.wallet!.get();
        walletName = walletSnap.get('name');
        walletId = walletSnap.id;
      }
    } catch (e) {
      print('Error fetching related documents: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202020),
        title: Text('Transaction Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showBottomSheet(
                context,
                widget.transaction.title,
                widget.transaction.id,
                widget.transaction.amount,
                widget.transaction.isIncome,
                walletId!,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: widget.catColor,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Color(0xFF4b5563), width: 0.3),
                    ),
                    child: Icon(
                      transaction.isIncome
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${transaction.isIncome ? '' : '-'}${NumberFormat("#,##0.00", "en_US").format(transaction.amount.abs())} ฿',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202020),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFc2c2c2), width: 0.2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.category,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Type of payment',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              typeName ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        const Divider(
                          color: Colors.white24,
                          thickness: 0.5,
                          height: 16,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Payment wallet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              walletName ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        const Divider(
                          color: Colors.white24,
                          thickness: 0.5,
                          height: 16,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.date_range_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Date time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              formatDate(transaction.date),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(
    BuildContext context,
    String label,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF202020),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Delete Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Are you sure you want to delete "$label"?',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff343434),
                        shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  void _showBottomSheet(
    BuildContext parentContext,
    String label,
    String transactionId,
    double amount,
    bool isIncome,
    String walletId,
  ) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: const Color(0xFF202020),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.zero,
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF858585),
                      width: 0.3,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xff343434),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete, color: Colors.red[400], size: 20),
                  ),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(
                      bottomSheetContext,
                    ); // Close bottom sheet only

                    final confirm = await _showDeleteConfirmationDialog(
                      parentContext,
                      label,
                    );

                    if (confirm == true) {
                      await transactionservices.deleteTransaction(
                        transactionId,
                      );
                      await walletServices.reverseWalletBalanceChange(
                        walletId: walletId,
                        amountChange: amount,
                        isIncome: isIncome,
                      );

                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          backgroundColor: Color(0xFF292e31),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: const Color(0xFFc2c2c2),
                              width: 0.3,
                            ),
                          ),
                          content: Row(
                            children: const [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Transaction deleted successfully',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      Navigator.pop(parentContext, true);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

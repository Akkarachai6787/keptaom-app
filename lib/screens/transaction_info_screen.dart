import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/services/transaction_services.dart';
import 'package:keptaom/services/wallet_services.dart';

class TransactionInfoScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionInfoScreen({super.key, required this.transaction});

  @override
  State<TransactionInfoScreen> createState() => _TransactionInfoScreenState();
}

class _TransactionInfoScreenState extends State<TransactionInfoScreen> {
  String? typeName;
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
      appBar: AppBar(
        title: Text('Transaction Info'),
        backgroundColor: const Color(0xFF111827),
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

      backgroundColor: const Color(0xFF111827),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF4b5563),
                              width: 0.3,
                            ),
                          ),
                          child: Text(
                            _formatDate(transaction.date),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '฿ ${transaction.amount.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            color: transaction.isIncome
                                ? Colors.teal[500]
                                : Colors.red[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),

                  // TYPE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1f2937),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF4b5563), width: 0.3),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.category,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            typeName ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // WALLET
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1f2937),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF4b5563), width: 0.3),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            walletName ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<bool> _showDeleteConfirmationDialog(
    BuildContext context,
    String label,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
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
                  fontWeight: FontWeight.bold,
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
                        backgroundColor: const Color.fromARGB(
                          38,
                          178,
                          223,
                          219,
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
    BuildContext parentContext, // context of the screen that opens the sheet
    String label,
    String transactionId,
    double amount,
    bool isIncome,
    String walletId,
  ) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: const Color(0xFF111827),
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
                  fontSize: 16,
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
                      color: const Color(0xFF4b5563),
                      width: 0.3,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(38, 178, 223, 219),
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
                        backgroundColor: const Color(0xFF1f2937),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Color(0xFF4b5563),
                            width: 0.5,
                          ),
                        ),
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle_outline, color: Colors.teal),
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

                      Navigator.pop(parentContext, true); // Pop full page
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

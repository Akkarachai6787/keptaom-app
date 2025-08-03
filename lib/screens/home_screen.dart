import 'package:flutter/material.dart';
import 'package:keptaom/services/wallet_services.dart';
import 'package:keptaom/models/wallet.dart';
import 'package:keptaom/widgets/wallet_widgets.dart';
import 'manage_wallet_screen.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/services/transaction_services.dart';
import 'package:keptaom/widgets/transaction_item.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/services/category_services.dart';
import 'package:keptaom/services/auth_services.dart';
import 'add_transaction_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

final String name = "Akkarachai";

class _HomeContentState extends State<Home> {
  List<Wallet> wallets = [];
  final walletService = WalletServices();
  List<TransactionModel> transactions = [];
  final transactionservices = Transactionservices();
  List<CategoryTransaction?> transactionCategories = [];
  final categoryService = CategoryServices();
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadWallets();
    loadTransactions();
  }

  Future<void> loadWallets() async {
    final data = await walletService.fetchWallets();
    setState(() {
      wallets = data;
    });
  }

  Future<void> loadTransactions() async {
    final data = await transactionservices.fetchTransactions();

    final List<Future<CategoryTransaction?>> futures = data
        .map((tx) => CategoryServices().fetchCategoryById(tx.typeId))
        .toList();

    final categories = await Future.wait(futures);

    setState(() {
      transactions = data;
      transactionCategories = categories;
    });
  }

  Future<void> _deleteWallet(String walletId) async {
    try {
      await walletService.deleteWallet(walletId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF292e31),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: const Color(0xFFc2c2c2), width: 0.3),
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.teal),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Wallet deleted successfully',
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

      await loadWallets();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF1f2937),
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error deleting wallet: $e',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _navigateToManageWallet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Managewallet()),
    );

    if (result == true) {
      loadWallets();
    }
  }

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTransactionScreen()),
    );

    if (result == true) {
      loadWallets();
      loadTransactions(); // รีโหลดหลังเพิ่ม
    }
  }

  Future<bool> _showDeleteConfirmationDialog(
    BuildContext context,
    String label,
  ) async {
    bool confirmed = false;

    await showModalBottomSheet(
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
                'Delete Wallet',
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
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: () {
                        confirmed = true;
                        Navigator.pop(context);
                      },
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
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF202020),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Welcome',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 6),
            user != null
                ? Text('${user.email}')
                : Text(
                    '$name !',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 16,
            right: 16,
            bottom: 0,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Balance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: PageView(
                  controller: PageController(viewportFraction: 0.9),
                  children: [
                    ...wallets.map(
                      (wallet) => WalletBalanceCard(
                        label: wallet.label,
                        amount: wallet.amount,
                        onLongPress: () =>
                            _showBottomSheet(context, wallet.label),
                      ),
                    ),
                    AddWalletCard(onTap: _navigateToManageWallet),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border(
                      left: BorderSide(
                        color: const Color(0xFF858585),
                        width: 0.3,
                      ),
                      right: BorderSide(
                        color: const Color(0xFF858585),
                        width: 0.3,
                      ),
                      top: BorderSide(
                        color: const Color(0xFF858585),
                        width: 0.3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transactions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.white),
                            onPressed: _navigateToAddTransaction,
                            tooltip: 'Add Transaction',
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: List.generate(transactions.length, (i) {
                              final category = i < transactionCategories.length
                                  ? transactionCategories[i]
                                  : null;

                              return TransactionItem(
                                transaction: transactions[i],
                                category: category,
                                onUpdate: () async {
                                  await loadTransactions();
                                  await loadWallets();
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, String label) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF202020),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 0),
              ...['Edit', 'Delete'].map((action) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
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
                        color: const Color(0xFF343434),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        action == 'Edit' ? Icons.edit : Icons.delete,
                        color: action == 'Edit'
                            ? Colors.white
                            : Colors.red[400],
                        size: 20,
                      ),
                    ),
                    title: Text(
                      action,
                      style: TextStyle(
                        color: action == 'Edit'
                            ? Colors.white
                            : Colors.red[400],
                      ),
                    ),

                    onTap: () async {
                      Navigator.pop(context);
                      final wallet = wallets.firstWhere(
                        (w) => w.label == label,
                      );

                      if (action == 'Edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Managewallet(wallet: wallet),
                          ),
                        );
                        if (result == true) {
                          loadWallets();
                        }
                      } else if (action == 'Delete') {
                        final confirm = await _showDeleteConfirmationDialog(
                          context,
                          label,
                        );
                        if (confirm == true) {
                          await _deleteWallet(wallet.id);
                        }
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

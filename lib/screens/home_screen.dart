import 'package:flutter/material.dart';
import 'package:keptaom/services/wallet_services.dart';
import 'package:keptaom/models/wallet.dart';
import 'package:keptaom/widgets/wallet_widgets.dart';
import 'package:keptaom/widgets/bill_widget.dart';
import 'manage_wallet_screen.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/services/transaction_services.dart';
import 'package:keptaom/widgets/transaction_item.dart';
import '../models/budget.dart';
import '../services/budget_services.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/services/category_services.dart';
import 'package:keptaom/services/auth_services.dart';
import 'package:keptaom/services/user_services.dart';
import '../models/bill.dart';
import '../services/bill_services.dart';
import '../screens/add_bill_screen.dart';
import 'package:keptaom/models/user.dart';
import 'add_transaction_screen.dart';
import 'package:keptaom/widgets/snack_bar.dart';

class Home extends StatefulWidget {
  final String userId;
  final VoidCallback? onNavigateToTransactions;
  final VoidCallback? onNavigateToBills;

  const Home({
    super.key,
    required this.userId,
    this.onNavigateToTransactions,
    this.onNavigateToBills,
  });

  @override
  State<Home> createState() => _HomeContentState();
}

class _HomeContentState extends State<Home> {
  List<Wallet> wallets = [];
  final walletService = WalletServices();
  Budget? budget;
  Map<String, double> budgetContributionsWithLabel = {};
  final budgetServices = BudgetServices();
  List<TransactionModel> transactions = [];
  final transactionservices = Transactionservices();
  List<CategoryTransaction?> transactionCategories = [];
  final categoryService = CategoryServices();
  final authService = AuthService();
  final userService = UserServices();
  final billServices = BillService();
  List<Bill> bills = [];
  UserModel? userData;
  late String? userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    loadUserAndData();
  }

  Future<void> loadUserAndData() async {
    setState(() {
      isLoading = true;
    });

    await loadUser();
    await loadWallets();
    if (userData != null && userData!.enableBudget) {
      loadBudget();
    }
    await loadBills();
    await loadTransactions();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadUser() async {
    final currentUser = authService.currentUser?.uid;
    if (currentUser != null) {
      final data = await userService.getUserInfo(currentUser);
      if (data != null) {
        final userModel = UserModel.fromMap(data);
        setState(() {
          userData = userModel;
        });
      }
    }
  }

  Future<void> loadWallets() async {
    if (userId == null) {
      return;
    }
    final data = await walletService.fetchWallets(userId!);
    setState(() {
      wallets = data;
    });
  }

  Future<void> loadBills() async {
    if (userId == null) {
      return;
    }

    final result = await billServices.getBillsLimitByUser(userId!, 5);
    setState(() {
      bills = result;
    });
  }

  Future<void> loadBudget() async {
    if (userId == null) return;

    final data = await budgetServices.fetchBudgets(userId!);

    if (data.isEmpty) return;

    final loadedBudget = data.first;

    setState(() {
      budget = loadedBudget;
    });
  }

  Future<void> loadTransactions() async {
    if (userId == null) {
      return;
    }
    final data = await transactionservices.fetchLastestTransactions(
      uid: userId!,
      limit: 5,
    );

    final List<Future<CategoryTransaction?>> futures = data
        .map((tx) => categoryService.fetchCategoryById(tx.typeId))
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
      await transactionservices.deleteTransactionsByWalletId(walletId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF292e31),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: const Color(0xFFc2c2c2), width: 0.3),
          ),
          content: SnackBarWidget(
            isError: false,
            message: 'Wallet deleted successfully',
          ),
        ),
      );

      await loadWallets();
      await loadTransactions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF292e31),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: const Color(0xFFc2c2c2), width: 0.3),
          ),
          content: SnackBarWidget(
            isError: true,
            message: 'Error deleting wallet: $e',
          ),
        ),
      );
    }
  }

  Future<void> _navigateToManageWallet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Managewallet(userId: userId!)),
    );

    if (result == true) {
      await loadWallets();
      await loadTransactions();
      await loadBudget();
    }
  }

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTransactionScreen(userId: userId)),
    );

    if (result == true) {
      await loadWallets();
      await loadTransactions();
      await loadBudget();
    }
  }

  Future<void> _navigateToViewTransaction() async {
    if (widget.onNavigateToTransactions != null) {
      widget.onNavigateToTransactions!();
    }
  }

  Future<void> _navigateToAddBill() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddBillScreen(userId: userId)),
    );

    if (result == true) {
      await loadBills();
    }
  }

  Future<void> _navigateToViewBill() async {
    if (widget.onNavigateToBills != null) {
      widget.onNavigateToBills!();
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
                            builder: (_) =>
                                Managewallet(wallet: wallet, userId: userId!),
                          ),
                        );
                        if (result == true) {
                          await loadWallets();
                          await loadTransactions();
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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),
          )
        : Scaffold(
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
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${userData!.name}!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: _navigateToAddTransaction,
                  icon: const Icon(Icons.add, color: Colors.white, size: 26),
                  tooltip: 'Add transaction',
                ),
              ],
              actionsPadding: EdgeInsets.only(right: 16),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your balance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: PageView(
                        controller: PageController(viewportFraction: 0.8),
                        padEnds: false,
                        children: [
                          if (userData!.enableBudget) ...[
                            BalanceCard(amount: budget!.amount),
                          ],
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

                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming bills',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToViewBill,
                            child: Text(
                              'View all',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF9AAABB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 130,
                      child: PageView(
                        controller: PageController(viewportFraction: 0.45),
                        padEnds: false,
                        children: [
                          ...bills.map(
                            (b) => BillCard(
                              title: b.title,
                              amount: b.amount,
                              date: b.date.toDate(),
                              isPaid: b.isPaid,
                            ),
                          ),

                          AddWalletCard(onTap: _navigateToAddBill),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 8,
                            bottom: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF292e31),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Transactions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _navigateToViewTransaction,
                                    child: Text(
                                      'View all',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF9AAABB),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(transactions.length, (
                                  i,
                                ) {
                                  final category =
                                      i < transactionCategories.length
                                      ? transactionCategories[i]
                                      : null;

                                  return TransactionItem(
                                    transaction: transactions[i],
                                    userId: widget.userId,
                                    category: category,
                                    onUpdate: () async {
                                      await loadTransactions();
                                      await loadWallets();
                                      await loadBudget();
                                    },
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

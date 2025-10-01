import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/services/category_services.dart';
import 'package:keptaom/services/transaction_services.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/utils/format_date.dart';
import 'package:keptaom/screens/transaction_info_screen.dart';
import 'package:keptaom/utils/color_utils.dart';
import 'package:keptaom/widgets/pick_datetime.dart';
import 'package:keptaom/widgets/snack_bar.dart';

class AllTransaction extends StatefulWidget {
  final String userId;

  const AllTransaction({super.key, required this.userId});

  @override
  State<AllTransaction> createState() => _AllTransactionState();
}

class _AllTransactionState extends State<AllTransaction> {
  final transactionService = Transactionservices();
  final categoryService = CategoryServices();
  final ScrollController _scrollController = ScrollController();

  List<TransactionModel> transactions = [];
  List<CategoryTransaction?> transactionCategories = [];
  String? lastId;
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 20;

  DateTime? _selectedDate;
  String? _selectedMonthString;
  late int _selectedMonth;
  late int _selectedYear;
  bool? shouldRefresh = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _selectedMonthString = DateFormat.MMMM().format(now);
    _selectedDate = DateTime(_selectedYear, _selectedMonth);

    _loadMore();
    _fetchCategories();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore) {
      _loadMore();
    }
  }

  Future<void> _onSelectMonthYear() async {
    final result = await MonthYearPicker.show(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (result != null) {
      setState(() {
        _selectedMonthString = result['monthString'];
        _selectedMonth = result['month'];
        _selectedYear = result['year'];
        _selectedDate = DateTime(_selectedYear, _selectedMonth);

        transactions.clear();
        lastId = null;
        hasMore = true;
      });
      await _loadMore();
    }
  }

  Future<void> _refreshTransactions() async {
    if (!mounted) return;
    setState(() {
      transactions.clear();
      lastId = null;
      hasMore = true;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (isLoading || !mounted) return;
    setState(() => isLoading = true);

    try {
      final result = await transactionService.fetchAllTransactions(
        uid: widget.userId,
        limit: limit,
        lastId: lastId,
        month: _selectedMonth,
        year: _selectedYear,
      );

      debugPrint('month $_selectedMonth');
      if (!mounted) return;

      setState(() {
        transactions.addAll(result.transactions);
        lastId = result.lastId;
        if (result.transactions.length < limit) {
          hasMore = false;
        }
        isLoading = false;
      });
    } catch (e, st) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint('Failed to load transactions: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF292e31),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFc2c2c2), width: 0.3),
          ),
          content: SnackBarWidget(
            isError: true,
            message: 'Failed to load transactions',
          ),
        ),
      );
    }
  }

  Future<void> _fetchCategories() async {
    final data = await categoryService.fetchCategories(widget.userId);

    setState(() {
      transactionCategories = data;
    });
  }

  String? getCategoryName(String typeId) {
    if (transactionCategories.isEmpty) {
      return 'Unknown';
    }

    final category = transactionCategories.firstWhere(
      (cat) => cat?.id == typeId,
      orElse: () => CategoryTransaction(
        id: '',
        title: 'Unknown',
        color: 'Unknown',
        isIncome: true,
      ),
    );
    return category?.color;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          'Transactions history',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_selectedMonthString $_selectedYear',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  child: IconButton(
                    icon: Icon(Icons.calendar_month_rounded),
                    color: Colors.white,
                    iconSize: 24,
                    onPressed: _onSelectMonthYear,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: transactions.length + 1,
                itemBuilder: (context, index) {
                  if (index < transactions.length) {
                    final tx = transactions[index];
                    final hexString = getCategoryName(tx.typeId);
                    final catColor = hexString != null
                        ? hexToColor(hexString)
                        : Colors.white;

                    BorderRadius borderRadius;
                    if (transactions.length == 1) {
                      borderRadius = BorderRadius.circular(20);
                    } else if (index == 0) {
                      borderRadius = const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      );
                    } else if (index == transactions.length - 1) {
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
                      border: index != transactions.length - 1
                          ? const Border(
                              bottom: BorderSide(
                                color: Color(0xFF66737A),
                                width: 0.3,
                              ),
                            )
                          : null,
                    );

                    return GestureDetector(
                      onTap: () async {
                        shouldRefresh = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionInfoScreen(
                              transaction: tx,
                              catColor: catColor,
                              userId: widget.userId,
                            ),
                          ),
                        );
                        if (shouldRefresh == true) {
                          _refreshTransactions();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: decoration,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: catColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                tx.isIncome
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                      ),
                    );
                  } else {
                    return hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 4,
                              ),
                            ),
                          )
                        : const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

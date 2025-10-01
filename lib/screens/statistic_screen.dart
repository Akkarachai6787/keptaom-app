import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/services/bill_services.dart';
import 'package:keptaom/widgets/pick_datetime.dart';
import 'package:keptaom/widgets/pie_chart.dart';
// import 'package:keptaom/widgets/progress_widget.dart';
import 'package:keptaom/widgets/categories_item.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/services/transaction_services.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/services/category_services.dart';
import '../models/budget.dart';
import '../services/budget_services.dart';

class StatisticScreen extends StatefulWidget {
  final String userId;

  const StatisticScreen({super.key, required this.userId});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen>
    with SingleTickerProviderStateMixin {
  List<TransactionModel> transactions = [];
  List<TransactionModel> othersTransactions = [];
  final transactionservices = Transactionservices();
  List<CategoryTransaction?> transactionCategories = [];
  List<CategoryTransaction?> othersTransactionCategories = [];
  final categoryService = CategoryServices();
  final budgetServices = BudgetServices();
  Budget? budget;
  final billServices = BillService();

  Map<String, double> categoryTotals = {};
  Map<String, double> othersCategoryTotals = {};
  Map<String, double> categoryPercents = {};
  double totalPayment = 0.0;
  double expensePer = 0.0;
  double recommendExpense = 0.0;
  double leftRec = 0.0;

  Map<String, List<TransactionModel>> categoryTransactionsMap = {};
  Map<String, List<TransactionModel>> categoryOthersTransactionsMap = {};

  TabController? _tabController;

  DateTime? _selectedDate;
  String? _selectedMonthString;
  int? _selectedMonth;
  int? _selectedYear;
  int _currentTabIndex = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initPage();

    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _selectedMonthString = DateFormat.MMMM().format(now);
    _selectedDate = DateTime(_selectedYear!, _selectedMonth!);

    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController!.index;
        });
      }
    });

    _loadAllData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _initPage() async {
    loadTransactions();
  }

  Future<void> _loadAllData() async {
    await loadTransactions();
    await loadBudget();
    if (budget != null) {
      await checkBudgetCycle(leftRec);
    }
  }

  Future<void> loadTransactions() async {
    setState(() {
      isLoading = true;
    });

    final data = await transactionservices.getTransactionsForAnalyze(
      userId: widget.userId,
      month: _selectedMonth!,
      year: _selectedYear!,
    );

    final normalList = data['forAnalyze']!;
    final otherTransactions = data['otherLists']!;

    final List<Future<CategoryTransaction?>> futures = normalList
        .map(
          (tx) => categoryService.fetchCategoryById(tx.typeId),
        )
        .toList();

    final categories = await Future.wait(futures);

    final List<Future<CategoryTransaction?>> otherFutures = otherTransactions
        .map(
          (tx) => categoryService.fetchCategoryById(tx.typeId),
        )
        .toList();

    final otherCategories = await Future.wait(otherFutures);

    final Map<String, CategoryTransaction> categoryMap = {};
    final Map<String, double> totalsByCategory = {};
    final Map<String, double> totalsOthersByCategory = {};

    final Map<String, List<TransactionModel>> groupedTransactions = {};

    double totalForPercent = 0;
    double totalNet = 0;

    double sumIncome = 0;
    double sumExpense = 0;
    double recExpense = 0;
    double expensePercent = 0;
    double leftRecommend = 0;

    for (int i = 0; i < normalList.length; i++) {
      final tx = normalList[i];
      final cat = categories[i];

      if (cat != null) {
        final signedAmount = cat.isIncome ? tx.amount : -tx.amount;

        cat.isIncome ? sumIncome += tx.amount : sumExpense += tx.amount;

        totalsByCategory[cat.id] =
            (totalsByCategory[cat.id] ?? 0) + signedAmount;
        categoryMap[cat.id] = cat;

        totalNet += signedAmount;
        totalForPercent += tx.amount;

        groupedTransactions[cat.id] = (groupedTransactions[cat.id] ?? [])
          ..add(tx);
      }
    }

    final Map<String, double> percentByCategory = {};
    totalsByCategory.forEach((id, total) {
      percentByCategory[id] = totalForPercent > 0
          ? (total.abs() / totalForPercent) * 100
          : 0;
    });

    recExpense = (sumIncome * 0.35);
    expensePercent = recExpense > 0 ? (sumExpense / recExpense) * 100 : 0;
    leftRecommend = recExpense - sumExpense;

    final Map<String, CategoryTransaction> otherCategoryMap = {};
    final Map<String, List<TransactionModel>> otherGroupedTransactions = {};

    for (int i = 0; i < otherTransactions.length; i++) {
      final tx = otherTransactions[i];
      final cat = otherCategories[i];

      if (cat != null) {
        final signedAmount = cat.isIncome ? tx.amount : -tx.amount;

        totalsOthersByCategory[cat.id] =
            (totalsOthersByCategory[cat.id] ?? 0) + signedAmount;

        otherCategoryMap[cat.id] = cat;

        otherGroupedTransactions[cat.id] =
            (otherGroupedTransactions[cat.id] ?? [])..add(tx);
      }
    }

    setState(() {
      transactions = normalList;
      othersTransactions = otherTransactions;
      transactionCategories = categoryMap.values.toList();
      othersTransactionCategories = otherCategoryMap.values.toList();
      othersCategoryTotals = totalsOthersByCategory;
      categoryTotals = totalsByCategory;
      categoryPercents = percentByCategory;
      totalPayment = totalNet;
      categoryTransactionsMap = groupedTransactions;
      categoryOthersTransactionsMap = otherGroupedTransactions;
      recommendExpense = recExpense;
      expensePer = expensePercent;
      leftRec = leftRecommend;
      isLoading = false;
    });
  }

  Future<void> loadBudget() async {
    final data = await budgetServices.fetchBudgets(widget.userId);

    if (data.isEmpty) return;

    final loadedBudget = data.first;

    setState(() {
      budget = loadedBudget;
    });
  }

  bool isEndOfMonth(DateTime now) {
    final tomorrow = now.add(const Duration(days: 1));
    return tomorrow.month != now.month;
  }

  Future<void> checkBudgetCycle(double leftRec) async {
    final now = DateTime.now();
    final actual = leftRec < 0 ? 0.0 : leftRec;

    await budgetServices.startOfMonthBudget(budget!.id);

    final isLastDay = now.add(const Duration(days: 1)).month != now.month;
    final isAfter9PM = now.hour >= 21;

    if (isLastDay && isAfter9PM) {
      final key = "${now.year}-${now.month.toString().padLeft(2, '0')}";
      final monthData = budget!.monthsAdded[key];

      if (monthData == null || monthData.finalized != true) {
        await budgetServices.endOfMonthBudget(budget!.id, actual);
        if (actual > 0) {
          await billServices.addBill(
            title: 'Budget - $key',
            amount: actual,
            date: now,
            isTransfer: true,
            typeId: 'budget',
            isPaid: false,
            uidId: widget.userId,
            repeatEnabled: false,
          );
        }
      }
    }
  }

  Future<void> _onSelectMonthYear() async {
    final result = await MonthYearPicker.show(
      context: context,
      initialDate: _selectedDate == null ? DateTime.now() : _selectedDate!,
    );

    if (result != null) {
      setState(() {
        _selectedMonthString = result['monthString'];
        _selectedMonth = result['month'];
        _selectedYear = result['year'];

        _selectedDate = DateTime(_selectedYear!, _selectedMonth!);
      });

      await loadTransactions();
    }
  }

  Map<String, double> get pieDataMap {
    final sortedCategories =
        transactionCategories
            .where((cat) => cat != null && (categoryPercents[cat.id] ?? 0) > 0)
            .toList()
          ..sort((a, b) {
            final percentA = categoryPercents[a!.id] ?? 0;
            final percentB = categoryPercents[b!.id] ?? 0;
            return percentA.compareTo(percentB);
          });

    final Map<String, double> map = {};
    for (var cat in sortedCategories) {
      map[cat!.title] = categoryPercents[cat.id] ?? 0;
    }
    return map;
  }

  List<Color> get pieColorList {
    final sortedCategories =
        transactionCategories
            .where(
              (cat) => cat != null && (categoryPercents[cat.id] ?? 0) > 0.0,
            )
            .toList()
          ..sort((a, b) {
            final percentA = categoryPercents[a!.id] ?? 0;
            final percentB = categoryPercents[b!.id] ?? 0;
            return percentA.compareTo(percentB);
          });

    return sortedCategories
        .map((cat) => Color(int.parse(cat!.color.replaceAll('#', '0xff'))))
        .toList();
  }

  List<Widget> _buildCategoryList(bool isIncome) {
    final filtered =
        transactionCategories
            .where((cat) => cat != null && cat.isIncome == isIncome)
            .toList()
          ..sort((a, b) {
            final percentA = categoryPercents[a!.id] ?? 0;
            final percentB = categoryPercents[b!.id] ?? 0;
            return percentB.compareTo(percentA);
          });

    return filtered.map((category) {
      final total = categoryTotals[category!.id] ?? 0;
      final percent = categoryPercents[category.id] ?? 0;

      return CategoriesItem(
        category: category,
        totalAmount: total,
        percent: percent,
        transactions: categoryTransactionsMap[category.id] ?? [],
        month: _selectedMonthString ?? 'Unknown',
        year: _selectedYear ?? DateTime.now().year,
        onRefresh: _initPage,
      );
    }).toList();
  }

  List<Widget> _buildOtherList() {
    return othersTransactionCategories.map((category) {
      final total = othersCategoryTotals[category!.id] ?? 0;

      return CategoriesItem(
        category: category,
        totalAmount: total,
        transactions: categoryOthersTransactionsMap[category.id] ?? [],
        month: _selectedMonthString ?? 'Unknown',
        year: _selectedYear ?? DateTime.now().year,
        onRefresh: _initPage,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202020),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Statistics",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 0,
            right: 16,
            bottom: 0,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedMonthString $_selectedYear',
                    style: TextStyle(
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
              if (pieDataMap.isEmpty != true) ...[
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 4,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf2f0ef),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFf2f0ef),
                            width: 0.3,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Your recommend expense',
                                  style: TextStyle(
                                    color: Color(0xFF111111),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  leftRec < 0
                                      ? '${NumberFormat("#,##0.00", "en_US").format(leftRec.abs())} ฿ over'
                                      : '${NumberFormat("#,##0.00", "en_US").format(leftRec)} ฿ left',
                                  style: TextStyle(
                                    color: leftRec < 0
                                        ? Color(0xFFD32F2F)
                                        : Color(0xFF111111),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                SizedBox(height: 24),
              ],
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 4,
                      ),
                    )
                  : Center(
                      child: pieDataMap.isEmpty
                          ? Column(
                              children: [
                                Icon(Icons.manage_search_rounded, size: 60),
                                SizedBox(height: 6),
                                Text(
                                  'No data to display',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : PieChartWidget(
                              dataMap: pieDataMap,
                              colorList: pieColorList,
                              totalPayment: totalPayment,
                            ),
                    ),

              SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: _currentTabIndex == 0
                    ? Colors.teal[600]
                    : _currentTabIndex == 1
                    ? Colors.red[600]
                    : Colors.white,

                tabs: const [
                  Tab(text: 'Income'),
                  Tab(text: 'Expense'),
                  Tab(text: 'Others'),
                ],
              ),
              Container(height: 0.3, color: const Color(0xFF4b5563)),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      child: Column(children: _buildCategoryList(true)),
                    ),
                    SingleChildScrollView(
                      child: Column(children: _buildCategoryList(false)),
                    ),
                    SingleChildScrollView(
                      child: Column(children: _buildOtherList()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/widgets/pick_datetime.dart';
import 'package:keptaom/widgets/pie_chart.dart';
import 'package:keptaom/widgets/progress_widget.dart';
import 'package:keptaom/widgets/categories_item.dart';
import 'package:keptaom/models/transaction.dart';
import 'package:keptaom/services/transaction_services.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/services/category_services.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen>
    with SingleTickerProviderStateMixin {
  List<TransactionModel> transactions = [];
  final transactionservices = Transactionservices();
  List<CategoryTransaction?> transactionCategories = [];
  final categoryService = CategoryServices();

  Map<String, double> categoryTotals = {};
  Map<String, double> categoryPercents = {};
  double totalPayment = 0.0;
  double expensePer = 0.0;
  double recommendExpense = 0.0;
  double leftRec = 0.0;

  Map<String, List<TransactionModel>> categoryTransactionsMap = {};

  TabController? _tabController;

  DateTime? _selectedDate;
  String? _selectedMonthString;
  int? _selectedMonth;
  int? _selectedYear;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initPage();

    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _selectedMonthString = DateFormat.MMMM().format(now);
    _selectedDate = DateTime(_selectedYear!, _selectedMonth!);

    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController!.index;
        });
      }
    });

    loadTransactions();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _initPage() async {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await transactionservices.getTransactionsByMonth(
      month: _selectedMonth!,
      year: _selectedYear!,
    );

    final List<Future<CategoryTransaction?>> futures = data
        .map((tx) => categoryService.fetchCategoryById(tx.typeId))
        .toList();

    final categories = await Future.wait(futures);

    final Map<String, CategoryTransaction> categoryMap = {};
    final Map<String, double> totalsByCategory = {};

    final Map<String, List<TransactionModel>> groupedTransactions = {};

    double totalForPercent = 0;
    double totalNet = 0;

    double sumIncome = 0;
    double sumExpense = 0;
    double recExpense = 0;
    double expensePercent = 0;
    double leftRecommend = 0;

    for (int i = 0; i < data.length; i++) {
      final tx = data[i];
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

    setState(() {
      transactions = data;
      transactionCategories = categoryMap.values.toList();
      categoryTotals = totalsByCategory;
      categoryPercents = percentByCategory;
      totalPayment = totalNet;
      categoryTransactionsMap = groupedTransactions;
      recommendExpense = recExpense;
      expensePer = expensePercent;
      leftRec = leftRecommend;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Statistics",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Income & Expense',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: _onSelectMonthYear,
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF4b5563),
                          width: 0.3,
                        ),
                        backgroundColor: const Color(0xFF1e293b),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Select M & Y'
                                : '$_selectedMonthString $_selectedYear',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 60),
              Center(
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

              SizedBox(height: pieDataMap.isEmpty ? 30 : 46),
              SizedBox(
                child: pieDataMap.isEmpty
                    ? Text('')
                    : ExpenseProgressWidget(
                        expensePercent: expensePer,
                        leftRecommended: leftRec,
                        isPositive: expensePer <= 100,
                      ),
              ),
              SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: _currentTabIndex == 0
                    ? Colors.teal[600]
                    : Colors.red[600],

                tabs: const [
                  Tab(text: 'Income'),
                  Tab(text: 'Expense'),
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

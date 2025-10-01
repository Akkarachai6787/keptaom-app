import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/widgets/dropdown_widget.dart';
import 'package:keptaom/widgets/pick_datetime.dart';
import 'package:keptaom/services/transaction_services.dart';
import 'package:keptaom/services/wallet_services.dart';
import 'package:keptaom/services/category_services.dart';
import 'package:keptaom/widgets/snack_bar.dart';
import '../services/budget_services.dart';
import '../models/list_combined.dart';

enum TransactionKind { income, expense, transfer }

class AddTransactionScreen extends StatefulWidget {
  final String? userId;

  const AddTransactionScreen({super.key, this.userId});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final walletServices = WalletServices();
  final transactionService = Transactionservices();
  final categoryService = CategoryServices();
  final budgetServices = BudgetServices();

  DateTime _selectedDate = DateTime.now();
  String? _selectedTypeId;
  String? _selectedWalletId;
  String? _typeError;
  String? _walletError;
  String? _fromWalletId;
  String? _toWalletId;
  String? _fromWalletError;
  String? _toWalletError;

  late bool _isIncome = true;
  late bool _isTransfer = false;
  TransactionKind _selectedKind = TransactionKind.income;

  List<CategoryTransaction> _incomeCategories = [];
  List<CategoryTransaction> _expenseCategories = [];
  List<CategoryTransaction> _visibleCategories = [];

  List<ListCombined> _walletList = [];
  List<ListCombined> _fromWalletList = [];

  @override
  void initState() {
    super.initState();
    _loadAllCategories();
    _loadAllWallets();
  }

  Future<void> _loadAllCategories() async {
    final income = await categoryService.fetchCategoriesIsIncome(
      true,
      widget.userId!,
    );
    final expense = await categoryService.fetchCategoriesIsIncome(
      false,
      widget.userId!,
    );

    const excludedId = "transfer";
    final filteredIncome = income.where((cat) => cat.id != excludedId).toList()
      ..sort((a, b) => a.title.compareTo(b.title.toLowerCase()));

    final sortedExpense = expense
      ..sort((a, b) => a.title.compareTo(b.title.toLowerCase()));

    setState(() {
      _incomeCategories = filteredIncome;
      _expenseCategories = sortedExpense;
      _visibleCategories = _incomeCategories;
    });
  }

  Future<void> _loadAllWallets() async {
    final list = await walletServices.fetchWallets(widget.userId!);
    final budgetW = await budgetServices.fetchBudgets(widget.userId!);

    final combinedMap = <String, ListCombined>{};
    final withoutBudget = <String, ListCombined>{};

    for (var w in list) {
      withoutBudget[w.id] = ListCombined(
        id: w.id,
        label: w.label,
        amount: w.amount,
        uidId: w.uidId,
      );

      combinedMap[w.id] = ListCombined(
        id: w.id,
        label: w.label,
        amount: w.amount,
        uidId: w.uidId,
      );
    }

    for (var b in budgetW) {
      combinedMap[b.id] = ListCombined(
        id: b.id,
        label: b.label,
        amount: b.amount,
        uidId: b.uidId,
      );
    }

    setState(() {
      _walletList = combinedMap.values.toList();
      _fromWalletList = withoutBudget.values.toList();
    });
  }

  void _toggleKind(TransactionKind kind) {
    setState(() {
      _selectedKind = kind;
      _selectedTypeId = null;
      _selectedWalletId = null;
      _fromWalletId = null;
      _toWalletId = null;

      _typeError = null;
      _walletError = null;
      _fromWalletId = null;
      _toWalletId = null;
      _fromWalletError = null;
      _toWalletError = null;

      if (_selectedKind == TransactionKind.income) {
        _isTransfer = false;
        _isIncome = true;
        _visibleCategories = _incomeCategories;
      } else if (_selectedKind == TransactionKind.expense) {
        _isTransfer = false;
        _isIncome = false;
        _visibleCategories = _expenseCategories;
      } else {
        _isTransfer = true;
        _isIncome = true;
        _visibleCategories = [];
      }
    });
  }

  Future<void> _saveTransaction() async {
    final isValid = _formKey.currentState!.validate();
    final budgetId = _walletList.firstWhere((w) => w.label == 'Budget').id;
    final budgetAmount = _walletList.firstWhere((w) => w.label == 'Budget').amount;

    setState(() {
      if (_selectedKind == TransactionKind.transfer) {
        _typeError = null;
        _walletError = null;
        _fromWalletError = _fromWalletId == null
            ? 'Please select a wallet'
            : null;
        _toWalletError = _toWalletId == null ? 'Please select a wallet' : null;
      } else {
        _typeError = _selectedTypeId == null ? 'Please select a type' : null;
        _walletError = _selectedWalletId == null
            ? 'Please select a wallet'
            : null;
        _fromWalletError = null;
        _toWalletError = null;
      }
    });

    final canSave =
        isValid &&
        _typeError == null &&
        _walletError == null &&
        _fromWalletError == null &&
        _toWalletError == null;

    if (canSave) {
      final title = _titleController.text.trim();
      final amount = double.tryParse(_amountController.text.trim()) ?? 0;

      try {
        if (_selectedKind == TransactionKind.transfer) {
          await transactionService.addTransaction(
            title: title,
            amount: amount,
            date: _selectedDate,
            isTransfer: _isTransfer,
            toWalletId: _toWalletId,
            isIncome: _isIncome,
            walletId: _fromWalletId!,
            userId: widget.userId!,
            typeId: 'transfer',
          );

          await walletServices.updateWalletBalance(
            walletId: _fromWalletId!,
            amountChange: amount,
            isIncome: false,
          );

          // if (_toWalletId == budgetId) {
          //   await budgetServices.updateBudgetBalance(
          //     id: _toWalletId!,
          //     amount: amount,
          //     // fromWalletId: _fromWalletId!,
          //   );
          // } else {
            await walletServices.updateWalletBalance(
              walletId: _toWalletId!,
              amountChange: amount,
              isIncome: true,
            );
          // }

          if (!mounted) return;
        } else {
          await transactionService.addTransaction(
            title: title,
            amount: amount,
            date: _selectedDate,
            isTransfer: _isTransfer,
            toWalletId: null,
            isIncome: _isIncome,
            walletId: _selectedWalletId!,
            userId: widget.userId!,
            typeId: _selectedTypeId!,
          );

          await walletServices.updateWalletBalance(
            walletId: _selectedWalletId!,
            amountChange: amount,
            isIncome: _isIncome,
          );

          if(_selectedTypeId == 'budget') {
            await budgetServices.updateBudgetBalance(
              id: budgetId,
              amount: amount,
              isIncome: _isIncome,
              currentAmount: budgetAmount,
              // fromWalletId: _fromWalletId!,
            );
          }

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color(0xFF292e31),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: const Color(0xFFc2c2c2), width: 0.3),
              ),
              content: SnackBarWidget(
                isError: false,
                message: 'Add "$title" successfully',
              ),
            ),
          );
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xFF292e31),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: const Color(0xFFc2c2c2), width: 0.3),
            ),
            content: SnackBarWidget(isError: true, message: 'Error: $e'),
          ),
        );
      }
    }
  }

  Future<String?> showDropdownTypesSelector({
    required BuildContext context,
    required List<CategoryTransaction> docs,
    required String Function(CategoryTransaction) fieldGetter,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) =>
          DropdownTypesSelectorSheet(docs: docs, fieldGetter: fieldGetter),
    );
  }

  Future<String?> showDropdownWalletSelector({
    required BuildContext context,
    required List<ListCombined> docs,
    required String Function(ListCombined) fieldGetter,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) =>
          DropdownWalletsSelectorSheet(docs: docs, fieldGetter: fieldGetter),
    );
  }

  Future<void> _pickDateTime() async {
    final picked = await DateTimePicker.show(
      context: context,
      initialDateTime: _selectedDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
        title: Text('Add transaction', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      showCheckmark: false,
                      side: BorderSide(
                        color: const Color(0xFF4b5563),
                        width: 0.3,
                      ),
                      label: Text('Income'),
                      selected: _selectedKind == TransactionKind.income,
                      onSelected: (val) => _toggleKind(TransactionKind.income),
                      selectedColor: Colors.teal[600],
                      labelStyle: TextStyle(
                        color: _selectedKind == TransactionKind.income
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Color(0xFF25292c),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: Text('Expense'),
                      showCheckmark: false,
                      side: BorderSide(
                        color: const Color(0xFF4b5563),
                        width: 0.3,
                      ),
                      selected: _selectedKind == TransactionKind.expense,
                      onSelected: (val) => _toggleKind(TransactionKind.expense),
                      selectedColor: Colors.red[600],
                      labelStyle: TextStyle(
                        color: _selectedKind == TransactionKind.expense
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Color(0xFF25292c),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: Text('Transfer'),
                      showCheckmark: false,
                      side: BorderSide(
                        color: const Color(0xFF4b5563),
                        width: 0.3,
                      ),
                      selected: _selectedKind == TransactionKind.transfer,
                      onSelected: (val) =>
                          _toggleKind(TransactionKind.transfer),
                      selectedColor: Colors.blue[600],
                      labelStyle: TextStyle(
                        color: _selectedKind == TransactionKind.transfer
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Color(0xFF25292c),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 50,
                    bottom: 30,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFc2c2c2),
                                width: 2,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2.5,
                              ),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2.5,
                              ),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2.5,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: 50,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the amount';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Input must be number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '฿',
                        style: TextStyle(color: Colors.white70, fontSize: 40),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration('Note'),
                    style: TextStyle(color: Colors.white),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter the note'
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                if (_selectedKind != TransactionKind.transfer) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final selected = await showDropdownTypesSelector(
                          context: context,
                          docs: _visibleCategories,
                          fieldGetter: (cat) => cat.title,
                        );
                        if (selected != null) {
                          setState(() {
                            _selectedTypeId = selected;
                            _typeError = null;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF202020),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                          side: BorderSide(
                            color: const Color(0xFFc2c2c2),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.category, color: Colors.white),
                              const SizedBox(width: 8),

                              if (_selectedTypeId != null &&
                                  _selectedTypeId == 'budget') ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _visibleCategories
                                          .firstWhere(
                                            (cat) => cat.id == _selectedTypeId,
                                          )
                                          .title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${NumberFormat("#,##0.00", "en_US").format(_walletList.firstWhere((w) => w.label == 'Budget').amount.abs())} ฿',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Text(
                                  _selectedTypeId != null
                                      ? _visibleCategories
                                            .firstWhere(
                                              (cat) =>
                                                  cat.id == _selectedTypeId,
                                            )
                                            .title
                                      : 'Select Type',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ],
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_typeError != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, left: 10),
                        child: Text(
                          _typeError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final selected = await showDropdownWalletSelector(
                          context: context,
                          docs: _fromWalletList,
                          fieldGetter: (cat) => cat.label,
                        );
                        if (selected != null) {
                          setState(() {
                            _selectedWalletId = selected;
                            _walletError = null;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF202020),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                          side: BorderSide(
                            color: const Color(0xFFc2c2c2),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_selectedWalletId != null) ...[
                                    Text(
                                      _fromWalletList
                                          .firstWhere(
                                            (w) => w.id == _selectedWalletId,
                                          )
                                          .label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${NumberFormat("#,##0.00", "en_US").format(_fromWalletList.firstWhere((w) => w.id == _selectedWalletId).amount.abs())} ฿',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      'Select Wallet',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_walletError != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, left: 10),
                        child: Text(
                          _walletError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                ] else ...[
                  Row(
                    children: [
                      SizedBox(width: 4),
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'From wallet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final availableFromWallets = _fromWalletList
                            .where((w) => w.id != _toWalletId)
                            .toList();

                        final selected = await showDropdownWalletSelector(
                          context: context,
                          docs: availableFromWallets,
                          fieldGetter: (cat) => cat.label,
                        );
                        if (selected != null) {
                          setState(() {
                            _fromWalletId = selected;
                            _fromWalletError = null;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF202020),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                          side: BorderSide(
                            color: const Color(0xFFc2c2c2),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_fromWalletId != null) ...[
                                    Text(
                                      _fromWalletList
                                          .firstWhere(
                                            (w) => w.id == _fromWalletId,
                                          )
                                          .label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${NumberFormat("#,##0.00", "en_US").format(_fromWalletList.firstWhere((w) => w.id == _fromWalletId).amount.abs())} ฿',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      'Select Wallet',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          _fromWalletId == null
                              ? const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _fromWalletId = null;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  if (_fromWalletError != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, left: 10),
                        child: Text(
                          _fromWalletError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 4),
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text('To wallet', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final availableToWallets = _fromWalletList
                            .where((w) => w.id != _fromWalletId)
                            .toList();

                        final selected = await showDropdownWalletSelector(
                          context: context,
                          docs: availableToWallets,
                          fieldGetter: (cat) => cat.label,
                        );

                        if (selected != null) {
                          setState(() {
                            _toWalletId = selected;
                            _toWalletError = null;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF202020),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                          side: BorderSide(
                            color: const Color(0xFFc2c2c2),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_toWalletId != null) ...[
                                    Text(
                                      _fromWalletList
                                          .firstWhere(
                                            (w) => w.id == _toWalletId,
                                          )
                                          .label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${NumberFormat("#,##0.00", "en_US").format(_fromWalletList.firstWhere((w) => w.id == _toWalletId).amount.abs())} ฿',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      'Select Wallet',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          _toWalletId == null
                              ? const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _toWalletId = null;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  if (_toWalletError != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, left: 10),
                        child: Text(
                          _toWalletError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                ],
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date: ${DateFormat.yMMMd().add_jm().format(_selectedDate)}',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      child: IconButton(
                        icon: Icon(Icons.calendar_month_rounded),
                        color: Colors.white,
                        iconSize: 24,
                        onPressed: _pickDateTime,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf2f0ef),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                  side: BorderSide(color: const Color(0xFFf2f0ef), width: 2),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111111),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 0.5),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 0.3),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 0.3),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 0.5),
      ),
      errorStyle: TextStyle(
        color: Colors.redAccent,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/models/wallet.dart';
import 'package:keptaom/widgets/dropdown_widget.dart';
import 'package:keptaom/widgets/pick_datetime.dart';
import 'package:keptaom/services/transaction_services.dart';
import 'package:keptaom/services/wallet_services.dart';
import 'package:keptaom/services/category_services.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

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

  DateTime _selectedDate = DateTime.now();
  String? _selectedTypeId;
  String? _selectedWalletId;
  String? _typeError;
  String? _walletError;
  bool _isIncome = true;

  List<CategoryTransaction> _incomeCategories = [];
  List<CategoryTransaction> _expenseCategories = [];
  List<CategoryTransaction> _visibleCategories = [];

  List<Wallet> _walletList = [];

  @override
  void initState() {
    super.initState();
    _loadAllCategories();
    _loadAllWallets();
  }

  Future<void> _loadAllCategories() async {
    final income = await categoryService.fetchCategoriesIsIncome(true);
    final expense = await categoryService.fetchCategoriesIsIncome(false);
    setState(() {
      _incomeCategories = income;
      _expenseCategories = expense;
      _visibleCategories = _isIncome ? _incomeCategories : _expenseCategories;
    });
  }

  Future<void> _loadAllWallets() async {
    final list = await walletServices.fetchWallets();
    setState(() {
      _walletList = list;
    });
  }

  void _toggleIncome(bool isIncome) {
    setState(() {
      _isIncome = isIncome;
      _visibleCategories = _isIncome ? _incomeCategories : _expenseCategories;
    });
  }

  Future<void> _saveTransaction() async {
    final isValid = _formKey.currentState!.validate();

    setState(() {
      _typeError = _selectedTypeId == null ? 'Please select a type' : null;
      _walletError = _selectedWalletId == null
          ? 'Please select a wallet'
          : null;
    });

    if (isValid && _typeError == null && _walletError == null) {
      final title = _titleController.text.trim();
      final amount = double.tryParse(_amountController.text.trim()) ?? 0;

      try {
        await transactionService.addTransaction(
          title: title,
          amount: amount,
          date: _selectedDate,
          isIncome: _isIncome,
          walletId: _selectedWalletId!,
          typeId: _selectedTypeId!,
        );

        await walletServices.updateWalletBalance(
          walletId: _selectedWalletId!,
          amountChange: amount,
          isIncome: _isIncome,
        );

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
                    'Add "$title" successfully',
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

        Navigator.pop(context, true);
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
                    'Error: $e',
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
    required List<Wallet> docs,
    required String Function(Wallet) fieldGetter,
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF202020),
        title: Text('Add Transaction'),
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
                      selected: _isIncome,
                      onSelected: (val) => _toggleIncome(true),
                      selectedColor: Colors.teal[600],
                      labelStyle: TextStyle(
                        color: _isIncome ? Colors.white : Colors.white70,
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
                      selected: !_isIncome,
                      onSelected: (val) => _toggleIncome(false),
                      selectedColor: Colors.red[600],
                      labelStyle: TextStyle(
                        color: !_isIncome ? Colors.white : Colors.white70,
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
                                color: Color(0xFF00897B),
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
                            Text(
                              _selectedTypeId != null
                                  ? _visibleCategories
                                        .firstWhere(
                                          (cat) => cat.id == _selectedTypeId,
                                        )
                                        .title
                                  : 'Select Type',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                        docs: _walletList,
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
                            Text(
                              _selectedWalletId != null
                                  ? _walletList
                                        .firstWhere(
                                          (cat) => cat.id == _selectedWalletId,
                                        )
                                        .label
                                  : 'Select Wallet',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date: ${DateFormat.yMMMd().add_jm().format(_selectedDate)}',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF25292c),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4b5563),
                          width: 0.3,
                        ),
                      ),
                      child: TextButton(
                        onPressed: _pickDateTime,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: Text(
                          'Pick DateTime',
                          style: TextStyle(color: Colors.white),
                        ),
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
                backgroundColor: const Color(0xFF202020),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                  side: BorderSide(color: const Color(0xFFc2c2c2), width: 2),
                ),
              ),
              child: const Text(
                'Add Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
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
        borderSide: BorderSide(color: Colors.teal, width: 0.5),
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

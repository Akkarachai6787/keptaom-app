import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keptaom/models/category_transaction.dart';
import '../services/bill_services.dart';
import '../services/wallet_services.dart';
import '../services/budget_services.dart';
import 'package:keptaom/services/category_services.dart';
import 'package:keptaom/widgets/dropdown_widget.dart';
import 'package:keptaom/widgets/pick_datetime.dart';
import '../widgets/bill_repeat_widget.dart';
import 'package:keptaom/widgets/snack_bar.dart';
import '../models/list_combined.dart';

class AddBillScreen extends StatefulWidget {
  final String? userId;

  const AddBillScreen({super.key, required this.userId});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  String? _selectedToWalletId;
  String? _selectedTypeId;
  String? _typeError;
  String? _toWalletError;

  bool _repeatEnabled = false;
  String? _repeatFrequency;
  int? _repeatInterval;
  DateTime? _repeatEndDate;

  late bool _isTransfer = false;
  final bool _isPaid = false;

  List<CategoryTransaction> _categories = [];
  List<ListCombined> _walletList = [];

  @override
  void initState() {
    super.initState();
    _loadAllCategories();
    _loadAllWallets();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadAllCategories() async {
    final cat = await CategoryServices().fetchCategoryById(
      'transfer',
    );
    final cat2 = await CategoryServices().fetchCategoryById(
      'bill',
    );

    setState(() {
      _categories = [];
      if (cat != null) _categories.add(cat);
      if (cat2 != null) _categories.add(cat2);
    });
  }

  Future<void> _loadAllWallets() async {
    final list = await WalletServices().fetchWallets(widget.userId!);
    final budgetW = await BudgetServices().fetchBudgets(widget.userId!);

    final combinedMap = <String, ListCombined>{};

    for (var w in list) {
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
    });
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();

    setState(() {
      if (_isTransfer && _selectedToWalletId == null) {
        _toWalletError = 'Please select a destination wallet for transfer';
      } else {
        _toWalletError = null;
      }
      _typeError = _selectedTypeId == null ? 'Please select a type' : null;
    });

    final canSave = isValid && _typeError == null && _toWalletError == null;

    if (canSave) {
      final title = _titleController.text.trim();
      final amount = double.tryParse(_amountController.text.trim()) ?? 0;

      try {
        await BillService().addBill(
          title: title,
          amount: amount,
          date: _selectedDate,
          isTransfer: _isTransfer,
          toWalletId: _selectedToWalletId,
          typeId: _selectedTypeId!,
          isPaid: _isPaid,
          walletId: null,
          uidId: widget.userId!,
          repeatEnabled: _repeatEnabled,
          repeatFrequency: _repeatFrequency,
          repeatInterval: _repeatInterval,
          repeatEndDate: _repeatEndDate,
        );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF202020),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Add bill', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Deadline: ${DateFormat.yMMMd().add_jm().format(_selectedDate)}',
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
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final selected = await showDropdownTypesSelector(
                        context: context,
                        docs: _categories,
                        fieldGetter: (cat) => cat.title,
                      );
                      if (selected != null) {
                        setState(() {
                          _selectedTypeId = selected;
                          _typeError = null;
                          debugPrint(selected);
                          if (selected == 'bill') {
                            _selectedToWalletId = null;
                            _isTransfer = false;
                          } else {
                            _isTransfer = true;
                          }
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
                                  ? _categories
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
                if (_selectedTypeId == 'transfer') ...[
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
                        final selected = await showDropdownWalletSelector(
                          context: context,
                          docs: _walletList,
                          fieldGetter: (cat) => cat.label,
                        );
                        if (selected != null) {
                          setState(() {
                            _selectedToWalletId = selected;
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
                                  if (_selectedToWalletId != null) ...[
                                    Text(
                                      _walletList
                                          .firstWhere(
                                            (w) => w.id == _selectedToWalletId,
                                          )
                                          .label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${NumberFormat("#,##0.00", "en_US").format(_walletList.firstWhere((w) => w.id == _selectedToWalletId).amount.abs())} ฿',
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
                          _selectedToWalletId == null
                              ? const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedToWalletId = null;
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

                RepeatBillPicker(
                  repeatEnabled: _repeatEnabled,
                  repeatFrequency: _repeatFrequency,
                  repeatInterval: _repeatInterval,
                  onChanged: (result) {
                    setState(() {
                      _repeatEnabled = result['enabled'] ?? false;
                      _repeatFrequency = result['frequency'];
                      _repeatInterval = result['interval'];
                    });
                  },
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
              onPressed: _submit,
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

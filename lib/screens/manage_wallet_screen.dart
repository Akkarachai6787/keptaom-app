import 'package:flutter/material.dart';
import 'package:keptaom/services/wallet_services.dart';
import 'package:keptaom/services/transaction_services.dart';
import 'package:keptaom/models/wallet.dart';
import 'package:keptaom/widgets/snack_bar.dart';

class Managewallet extends StatefulWidget {
  final Wallet? wallet;
  final String? userId;

  const Managewallet({super.key, this.wallet, this.userId});

  @override
  State<Managewallet> createState() => _ManagewalletState();
}

class _ManagewalletState extends State<Managewallet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final walletService = WalletServices();
  final transactionService = Transactionservices();
  late double oldBalance = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.wallet != null) {
      _nameController.text = widget.wallet!.label;
      _balanceController.text = widget.wallet!.amount.toString();
      oldBalance = widget.wallet!.amount;
    }
  }

  Future<void> _saveWallet() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final balance = double.tryParse(_balanceController.text.trim()) ?? 0;

      try {
        if (widget.wallet == null) {
          await walletService.addWallet(
            name: name,
            balance: balance,
            userId: widget.userId!,
          );
        } else {
          final difference = balance - oldBalance;

          await walletService.updateWallet(
            id: widget.wallet!.id,
            name: name,
            balance: balance,
          );

          if (difference != 0) {
            await transactionService.addTransaction(
              title: difference > 0 ? 'Some income' : 'Some expense',
              amount: difference,
              date: DateTime.now(),
              isTransfer: false,
              isIncome: difference > 0 ? true : false,
              walletId: widget.wallet!.id,
              userId: widget.userId!,
              typeId: difference > 0 ? 'otherIncome' : 'otherExpense',
            );
          }
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
              message: widget.wallet == null
                  ? 'Add "$name" successfully'
                  : 'Updated "$name" successfully',
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
          widget.wallet == null ? 'Add new wallet' : 'Edit wallet',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name of wallet',
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
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                        width: 0.5,
                      ),
                    ),
                    errorStyle: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter the name'
                      : null,
                ),
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6),
                child: TextFormField(
                  controller: _balanceController,
                  decoration: InputDecoration(
                    labelText: 'Balance',
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
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                        width: 0.5,
                      ),
                    ),
                    errorStyle: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the balance';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Input must be number';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveWallet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf2f0ef),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
                      side: BorderSide(
                        color: const Color(0xFFf2f0ef),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.wallet == null ? 'Add wallet' : 'Save changes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

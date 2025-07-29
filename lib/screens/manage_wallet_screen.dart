import 'package:flutter/material.dart';
import 'package:keptaom/services/wallet_services.dart';
import 'package:keptaom/models/wallet.dart';

class Managewallet extends StatefulWidget {
  final Wallet? wallet;

  const Managewallet({super.key, this.wallet});

  @override
  State<Managewallet> createState() => _ManagewalletState();
}

class _ManagewalletState extends State<Managewallet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final walletService = WalletServices();

  @override
  void initState() {
    super.initState();
    if (widget.wallet != null) {
      _nameController.text = widget.wallet!.label;
      _balanceController.text = widget.wallet!.amount.toString();
    }
  }

  Future<void> _saveWallet() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final balance = double.tryParse(_balanceController.text.trim()) ?? 0;

      try {
        if (widget.wallet == null) {
          // Add
          await walletService.addWallet(name, balance);
        } else {
          // Edit
          await walletService.updateWallet(widget.wallet!.id, name, balance);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          backgroundColor: Color(0xFF1f2937),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: const Color(0xFF4b5563), width: 0.5),
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.teal),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                    widget.wallet == null
                        ? 'Add "$name" successfully'
                        : 'Updated "$name" successfully',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet == null ? 'Add new wallet' : 'Edit wallet'),
        backgroundColor: const Color(0xFF111827),
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

              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveWallet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[800],
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.wallet == null ? 'Add wallet' : 'Save changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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

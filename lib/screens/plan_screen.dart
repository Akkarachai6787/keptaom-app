import 'package:flutter/material.dart';
import 'package:keptaom/screens/bill_screen.dart';
import '../screens/add_bill_screen.dart';

class PlanScreen extends StatefulWidget {
  final String userId;

  const PlanScreen({super.key, required this.userId});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  Key billScreenKey = UniqueKey();
  
  @override
  void initState() {
    super.initState();
  }

  Future<void> _navigateToAddBill() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddBillScreen(userId: widget.userId)),
    );

     if (result == true) {
      setState(() {
        billScreenKey = UniqueKey();
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
        title: Text(
          'Bills',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _navigateToAddBill,
            icon: const Icon(Icons.add, color: Colors.white, size: 26),
            tooltip: 'Add bill',
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 16),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: BillScreen(key: billScreenKey, userId: widget.userId,),
      ),
    );
  }
}

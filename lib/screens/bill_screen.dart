import 'package:flutter/material.dart';
import 'package:keptaom/services/budget_services.dart';
import '../models/budget.dart';
import 'package:keptaom/widgets/bill_widget.dart';
import 'package:keptaom/widgets/snack_bar.dart';
import '../services/bill_services.dart';
import '../models/bill.dart';

enum BillFilter { All, Upcoming, Due, OverDue, Paid }

class BillScreen extends StatefulWidget {
  final String userId;
  const BillScreen({super.key, required this.userId});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final billServices = BillService();
  final budgetServices = BudgetServices();
  BillFilter _selectedFilter = BillFilter.All;

  List<Bill> bills = [];
  Budget? budget;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadBills();
    _loadBudget();
  }

  Future<void> _loadBills() async {
    if (isLoading || !mounted) return;
    setState(() => isLoading = true);

    try {
      final result = await billServices.getBillsByUser(widget.userId);

      if (!mounted) return;

      setState(() {
        bills = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint('Failed to load bills: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF292e31),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFc2c2c2), width: 0.3),
          ),
          content: SnackBarWidget(
            isError: true,
            message: 'Failed to load bills',
          ),
        ),
      );
    }
  }

  Future<void> _loadBudget() async {
    final data = await budgetServices.fetchBudgets(widget.userId);

    if (data.isEmpty) return;

    final loadedBudget = data.first;

    setState(() {
      budget = loadedBudget;
    });
  }

  List<Bill> get filteredBills {
    DateTime today = DateTime.now();

    List<Bill> filtered = bills.where((bill) {
      DateTime date = bill.date.toDate();
      bool isPaid = bill.isPaid;

      switch (_selectedFilter) {
        case BillFilter.All:
          return true; // keep all for now
        case BillFilter.Paid:
          return isPaid;
        case BillFilter.Upcoming:
          return !isPaid && date.isAfter(today);
        case BillFilter.Due:
          return !isPaid &&
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
        case BillFilter.OverDue:
          return !isPaid && date.isBefore(today);
      }
    }).toList();

    if (_selectedFilter == BillFilter.All) {
      filtered.sort((a, b) {
        DateTime aDate = a.date.toDate();
        DateTime bDate = b.date.toDate();

        bool aPaid = a.isPaid;
        bool bPaid = b.isPaid;

        int aStatus;
        int bStatus;

        if (!aPaid && aDate.isBefore(today)) {
          aStatus = 0;
        } else if (!aPaid &&
            aDate.year == today.year &&
            aDate.month == today.month &&
            aDate.day == today.day) {
          aStatus = 1;
        } else if (!aPaid && aDate.isAfter(today)) {
          aStatus = 2;
        } else {
          aStatus = 3;
        }

        if (!bPaid && bDate.isBefore(today)) {
          bStatus = 0;
        } else if (!bPaid &&
            bDate.year == today.year &&
            bDate.month == today.month &&
            bDate.day == today.day) {
          bStatus = 1;
        } else if (!bPaid && bDate.isAfter(today)) {
          bStatus = 2;
        } else {
          bStatus = 3;
        }

        return aStatus.compareTo(bStatus);
      });
    }

    return filtered;
  }

  Future<bool> _showPaidConfirmationDialog(
    BuildContext context,
    Bill bill,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF202020),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paid Bill',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to mark as paid "${bill.title}"?',
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf2f0ef),
                        shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await billServices.markAsPaid(bill.id);
                        if (!mounted) return;

                        if (bill.repeatEnabled) {
                          await billServices.addRepeatBill(bill: bill);
                          if (!mounted) return;
                        }

                        Navigator.pop(context, true);

                        _loadBills();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF292e31),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Color(0xFFc2c2c2),
                                width: 0.3,
                              ),
                            ),
                            content: SnackBarWidget(
                              isError: false,
                              message: 'Bill marked as paid successfully',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Color(0xFF111111)),
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

    return result ?? false;
  }

  Future<bool> _showAddBudgetConfirmationDialog(
    BuildContext context,
    Bill bill,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF202020),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paid Bill',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to add budget "${bill.title}"?',
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf2f0ef),
                        shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await billServices.markAsPaid(bill.id);

                        await budgetServices.updateBudgetBalance(
                          id: budget!.id,
                          amount: bill.amount,
                          isIncome: true,
                          currentAmount: budget!.amount,
                        );
                        if (!mounted) return;

                        Navigator.pop(context, true);

                        _loadBills();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF292e31),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Color(0xFFc2c2c2),
                                width: 0.3,
                              ),
                            ),
                            content: SnackBarWidget(
                              isError: false,
                              message: 'Bill added budget successfully',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Color(0xFF111111)),
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

    return result ?? false;
  }

  Future<bool> _showDeleteConfirmationDialog(
    BuildContext context,
    String label,
  ) async {
    final result = await showModalBottomSheet<bool>(
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
                'Delete Bill',
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
                      onPressed: () => Navigator.pop(context, false),
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
                      onPressed: () => Navigator.pop(context, true),
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
    return result ?? false;
  }

  void _showBottomSheet(
    BuildContext parentContext,
    String label,
    String billId,
  ) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: const Color(0xFF202020),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
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
                      color: const Color(0xff343434),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete, color: Colors.red[400], size: 20),
                  ),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    final confirm = await _showDeleteConfirmationDialog(
                      parentContext,
                      label,
                    );

                    if (confirm == true) {
                      await billServices.deleteBill(billId);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Color(0xFF292e31),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: const Color(0xFFc2c2c2),
                              width: 0.3,
                            ),
                          ),
                          content: const SnackBarWidget(
                            isError: false,
                            message: 'Bill deleted successfully',
                          ),
                        ),
                      );

                      _loadBills();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: BillFilter.values.map((f) {
              final isSelected = _selectedFilter == f;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(
                    f.toString().split('.').last,
                    style: TextStyle(
                      color: isSelected ? Color(0xFF111111) : Colors.white70,
                    ),
                  ),
                  selectedColor: Color(0xFFf2f0ef),
                  backgroundColor: const Color(0xFF202020),
                  selected: isSelected,
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = f;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),
        isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              )
            : Expanded(
                child: GridView.builder(
                  itemCount: filteredBills.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final bill = filteredBills[index];
                    return BillCardItem(
                      title: bill.title,
                      amount: bill.amount,
                      date: bill.date.toDate(),
                      isPaid: bill.isPaid,
                      typeId: bill.typeId,
                      onPressed: () {
                        _showBottomSheet(context, bill.title, bill.id);
                      },
                      onMarkPaid: () {
                        if (bill.typeId == 'budget') {
                          _showAddBudgetConfirmationDialog(context, bill);
                        } else {
                          _showPaidConfirmationDialog(context, bill);
                        }
                      },
                    );
                  },
                ),
              ),
      ],
    );
  }
}

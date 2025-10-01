import 'package:flutter/material.dart';
import 'package:keptaom/models/category_transaction.dart';
import 'package:keptaom/services/auth_services.dart';
import 'package:keptaom/widgets/add_category.dart';
import 'package:keptaom/widgets/snack_bar.dart';
import '../services/user_services.dart';
import '../services/budget_services.dart';
import '../services/category_services.dart';
import '../models/user.dart';
import 'landing_screen.dart';
import 'package:keptaom/utils/color_utils.dart';

final rowDecor = BoxDecoration(
  color: const Color(0xFF202020),
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: Color(0xFFc2c2c2), width: 0.2),
);

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authService = AuthService();
  final budgetService = BudgetServices();
  final categoryServices = CategoryServices();
  final userServices = UserServices();

  List<CategoryTransaction?> transactionCategories = [];
  List<String?> categoriesColors = [];

  UserModel? userData;
  bool? isEnable;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserAndData();
  }

  Future<void> loadUserAndData() async {
    setState(() {
      isLoading = true;
    });

    await loadUserInfo();
    await loadCategories();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadUserInfo() async {
    final data = await userServices.getUserInfo(widget.userId);

    if (data != null) {
      final userModel = UserModel.fromMap(data);
      setState(() {
        userData = userModel;
        isEnable = userModel.enableBudget;
      });
    }
  }

  Future<void> loadCategories() async {
    final data = await categoryServices.fetchCategories(widget.userId);
    data.sort((a, b) {
      int incomeCompare = (b.isIncome ? 1 : 0) - (a.isIncome ? 1 : 0);
      if (incomeCompare != 0) return incomeCompare;

      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    final List<String> colorsList = data.map((cat) => cat.color).toList();

    setState(() {
      categoriesColors = colorsList;
      transactionCategories = data;
    });
  }

  void _openAddCategory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        catList: categoriesColors,
        onAdd: (title, isIncome, colorHex) async {
          try {
            final typeCreatedId = await categoryServices.addCategory(
              title: title,
              isIncome: isIncome,
              colorHex: colorHex,
            );

            await userServices.addTypeToUser(widget.userId, typeCreatedId);

            if (!mounted) return;

            await loadCategories();

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
        },
      ),
    );
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
          "My Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16,
            top: 16,
            right: 16,
            bottom: 0,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Financial Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: rowDecor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0x60FFFFFF),
                            width: 0.3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _openAddCategory(context),
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 4,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: transactionCategories.map((cat) {
                                    if (cat == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: hexToColor(cat.color),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            cat.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => {
                authService.signOut,
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LandingScreen()),
                  (route) => false,
                ),
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign out',
                style: TextStyle(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

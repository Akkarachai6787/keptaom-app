import 'package:flutter/material.dart';
import 'package:keptaom/screens/statistic_screen.dart';
import 'package:keptaom/screens/all_transaction_screen.dart';
import 'package:keptaom/screens/home_screen.dart';
import 'package:keptaom/screens/plan_screen.dart';
import 'package:keptaom/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  void _setTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      Home(userId: widget.userId, onNavigateToTransactions: () => _setTab(2), onNavigateToBills: () => _setTab(3),),
      StatisticScreen(userId: widget.userId),
      AllTransaction(userId: widget.userId),
      PlanScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId,),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: const Color(0xFF191919)),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFF535C65),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 26,
                child: Icon(
                  _selectedIndex == 0
                      ? Icons.home_rounded
                      : Icons.home_outlined,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 26,
                child: Icon(
                  _selectedIndex == 1
                      ? Icons.pie_chart_rounded
                      : Icons.pie_chart_outline,
                ),
              ),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 26,
                child: Icon(
                  _selectedIndex == 2
                      ? Icons.swap_vert_circle_rounded
                      : Icons.swap_vertical_circle_outlined,
                ),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 26,
                child: Icon(
                  _selectedIndex == 3
                      ? Icons.receipt_long_rounded
                      : Icons.receipt_long_outlined,
                ),
              ),
              label: 'Bills',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 26,
                child: Icon(
                  _selectedIndex == 4 ? Icons.person : Icons.person_outline,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

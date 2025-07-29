import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeptAom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Prompt',
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF111827),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Home(),
    Center(child: Text("Statistics", style: TextStyle(fontSize: 18))),
    Center(child: Text("Wishlists", style: TextStyle(fontSize: 18))),
    Center(child: Text("Account", style: TextStyle(fontSize: 18))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF030712),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF4b5563),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor:
              Colors.transparent,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 26,
                child: Icon(
                  _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 26,
                child: Icon(
                  _selectedIndex == 1
                      ? Icons.pie_chart
                      : Icons.pie_chart_outline,
                ),
              ),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 26,
                child: Icon(
                  _selectedIndex == 2 ? Icons.favorite : Icons.favorite_border,
                ),
              ),
              label: 'WishLists',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 26,
                child: Icon(
                  _selectedIndex == 3 ? Icons.person : Icons.person_outline,
                ),
              ),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}

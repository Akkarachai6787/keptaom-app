import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/landing_screen.dart';
import 'screens/home_screen.dart';
import 'screens/statistic_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  print("🔥 Firebase apps before init: ${Firebase.apps.length}");

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("✅ Firebase initialized");
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      print("⚠️ Firebase already initialized: ${e.message}");
    } else {
      print("❌ Firebase init failed: ${e.message}");
      rethrow; // Don't hide real errors
    }
  }

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
        scaffoldBackgroundColor: const Color(0xFF202020),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const HomeScreen(); 
        } else {
          return const LandingScreen(); 
        }
      },
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
    StatisticScreen(),
    Center(child: Text("Wishlists", style: TextStyle(fontSize: 18))),
    Center(child: Text("Account", style: TextStyle(fontSize: 18))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF999999),
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

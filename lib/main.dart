import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  debugPrint("🔥 Firebase apps before init: ${Firebase.apps.length}");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialized");
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      debugPrint("⚠️ Firebase already initialized: ${e.message}");
    } else {
      debugPrint("❌ Firebase init failed: ${e.message}");
      rethrow;
    }
  }

  runApp(const MyApp());
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Added dependency
import 'package:project_hope/services/ai_service.dart'; // Added to fire up Groq config
import 'firebase_options.dart';
import 'package:project_hope/view/loginpage.dart';
import 'package:project_hope/view/mainscreen.dart';

void main() async {
  // Ensures native platform channels are ready before initializing async processes
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load the environment parameters from disk securely first
  try {
    await dotenv.load(fileName: ".env");

    // 2. Initialize the dynamic Groq endpoint configurations now that keys are ready
    AIService.init();
  } catch (e) {
    // Gracefully logs if someone forgot to add the .env asset in pubspec
    debugPrint("Environment setup exception: $e");
  }

  // 3. Clean initialization pointing directly to your current local configurations
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProjectHope());
}

// Global Styling Constants to keep the theme predictable across files
const Color kBackgroundColor = Color(0xFF000000); // True black backing
const Color kPrimaryAccent = Colors.blueAccent; // Clean tech styling accent

class ProjectHope extends StatelessWidget {
  const ProjectHope({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project HOPE',
      debugShowCheckedModeBanner: false,

      // Enforcing a strict, dark UI sanctuary appearance globally
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackgroundColor,
        primaryColor: kPrimaryAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackgroundColor,
          elevation: 0,
        ),
      ),

      // Checks if an active session is already saved on the device disk
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. While reading the secure token on startup, show a clean loader
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: kBackgroundColor,
              body: Center(
                child: CircularProgressIndicator(color: kPrimaryAccent),
              ),
            );
          }

          // 2. If a valid login state exists, skip the login gate entirely
          if (snapshot.hasData && snapshot.data != null) {
            return const Mainscreen();
          }

          // 3. Default fallback if no user is authenticated
          return const LoginPage();
        },
      ),
    );
  }
}

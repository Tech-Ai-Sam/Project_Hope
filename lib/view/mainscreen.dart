// In lib/view/mainscreen.dart
import 'package:flutter/material.dart';
import 'package:project_hope/main.dart';
import 'package:project_hope/services/ai_service.dart'; 

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("HOPE", 
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: 15)),
            const Text("TECH AI INC. PROTOTYPE", 
              style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
            const SizedBox(height: 60),
            _buildMenuButton(context, "START ASSESSMENT", const DiagnosticHub()),
            const SizedBox(height: 20),
            // Ensure ChatScreen is also accessible or defined
            _buildMenuButton(context, "TALK TO HOPE AI", const ChatScreen()), 
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryAccent,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
      onPressed: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => page)
      ),
      child: Text(text, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
    );
  }
}
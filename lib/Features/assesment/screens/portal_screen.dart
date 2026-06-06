import 'package:flutter/material.dart';
import 'package:project_hope/Features/assesment/data/assessment_data.dart';

import 'quiz_screen.dart';

class AssessmentPortalScreen extends StatelessWidget {
  const AssessmentPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "REFLECTION SANCTUARY",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: appAssessments.length,
        itemBuilder: (context, index) {
          final config = appAssessments[index];
          return Card(
            color: Colors.white.withOpacity(0.02),
            margin: const EdgeInsets.symmetric(vertical: 8),
            // FIXED: Using 'side' inside RoundedRectangleBorder instead of 'border'
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: config.themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(config.icon, color: config.themeColor, size: 24),
              ),
              title: Text(
                config.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  config.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white30,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssessmentQuizScreen(config: config),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

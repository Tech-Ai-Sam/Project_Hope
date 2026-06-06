import 'package:flutter/material.dart';
import 'package:project_hope/main.dart'; // Pulls your global kPrimaryAccent styling

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  // Direct, relatable emotional statuses
  final List<Map<String, dynamic>> _statusOptions = [
    {
      "label": "Calm",
      "icon": Icons.wb_sunny_outlined,
      "color": Colors.tealAccent,
    },
    {
      "label": "Heavy / Sad",
      "icon": Icons.cloud_outlined,
      "color": Colors.blueAccent,
    },
    {
      "label": "Anxious",
      "icon": Icons.grain_rounded,
      "color": Colors.amberAccent,
    },
    {
      "label": "Energized",
      "icon": Icons.bolt_rounded,
      "color": Colors.orangeAccent,
    },
    {
      "label": "Angry",
      "icon": Icons.local_fire_department_rounded,
      "color": Colors.redAccent,
    },
  ];

  String _selectedStatus = "";

  // Generates a responsive greeting based on the current system time
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  void _handleStatusSelection(String status) {
    setState(() {
      _selectedStatus = status;
    });

    // Simple temporary alert feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Inner climate logged as $status"),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.white10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Immersive premium dark backdrop
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // --- PERSONALIZED HEADER ---
              Text(
                "${_getTimeBasedGreeting()},",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Siddharth".toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 40),

              // --- THE QUESTION PROMPT ---
              const Text(
                "How is your internal climate right now?",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 24),

              // --- INTERACTIVE STATUS GRID ---
              Column(
                children: _statusOptions.map((status) {
                  final bool isCurrentSelection =
                      _selectedStatus == status["label"];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () => _handleStatusSelection(status["label"]),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrentSelection
                              ? kPrimaryAccent.withOpacity(0.03)
                              : Colors.white.withOpacity(0.01),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrentSelection
                                ? kPrimaryAccent.withOpacity(0.4)
                                : Colors.white.withOpacity(0.03),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              status["icon"],
                              color: isCurrentSelection
                                  ? kPrimaryAccent
                                  : status["color"],
                              size: 22,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                status["label"],
                                style: TextStyle(
                                  color: isCurrentSelection
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 15,
                                  fontWeight: isCurrentSelection
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              isCurrentSelection
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              color: isCurrentSelection
                                  ? kPrimaryAccent
                                  : Colors.white.withOpacity(0.15),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

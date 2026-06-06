// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:project_hope/main.dart';
import 'package:project_hope/view/chatscreen.dart';
import 'package:project_hope/view/dignostichub.dart';
import 'package:project_hope/view/musicscreen.dart';
import 'package:project_hope/view/profile_screen.dart';
import 'package:project_hope/view/settingscreen.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int _currentIndex = 0;
  String? _assessmentResult;

  // Clean navigation routing map to keep the build cycle perfectly optimized
  List<Widget> _getPages() {
    return [
      _buildDashboardHome(), // Index 0: Home Panel
      const Musicscreen(), // Index 1: Calming Music Module
      const ProfileScreen(), // Index 2: Personal Profile Engine
      const SettingsPage(), // Index 3: App Modifications Control
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(index: _currentIndex, children: _getPages()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.03), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF070708), // Extra deep pitch grey
          selectedItemColor: kPrimaryAccent,
          unselectedItemColor: Colors.white30,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.grid_view_outlined, size: 20),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.grid_view_rounded, color: kPrimaryAccent),
              ),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.audiotrack_outlined, size: 20),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.audiotrack_rounded, color: kPrimaryAccent),
              ),
              label: 'MUSIC',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.shield_outlined, size: 20),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.shield_rounded, color: kPrimaryAccent),
              ),
              label: 'PROFILE',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.tune_outlined, size: 20),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.tune_rounded, color: kPrimaryAccent),
              ),
              label: 'SETTINGS',
            ),
          ],
        ),
      ),
    );
  }

  // Pure, Minimalist Landing Dashboard Redesign
  Widget _buildDashboardHome() {
    final bool isSevere = _assessmentResult == "Severe";
    final Color statusColor = _assessmentResult != null
        ? (isSevere ? Colors.redAccent : kPrimaryAccent)
        : Colors.white30;

    return Stack(
      children: [
        // Subtle ambient radial glow in the background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPrimaryAccent.withOpacity(0.08),
                Colors.black,
                Colors.black,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 28.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TOP BRAND APP BAR ROW ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "HOPE",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "INTELLIGENCE ENVIRONMENT",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.25),
                            fontSize: 9,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: kPrimaryAccent,
                        size: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // --- PREMIUM VISUAL MINDSET MONITOR ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: statusColor.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.02),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "SYSTEM STATUS MONITOR",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Live pulsating indicator circle
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _assessmentResult != null
                                  ? statusColor
                                  : Colors.greenAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_assessmentResult != null
                                              ? statusColor
                                              : Colors.greenAccent)
                                          .withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _assessmentResult != null
                            ? _assessmentResult!.toUpperCase()
                            : "OPTIMAL / IDLE",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _assessmentResult != null
                            ? "Baseline metric diagnostic complete."
                            : "No critical anomalies detected. Run engine diagnostics.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  "AVAILABLE OPERATIONS",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // --- TILED SYSTEM MODULE NAVIGATION BUTTONS ---
                _buildMenuCard(
                  context,
                  title: "Self Assessment",
                  subtitle: "Analyze baseline psychological metrics",
                  icon: Icons.bubble_chart_outlined,
                  destinationPage: const DiagnosticHub(),
                  isAssessment: true,
                ),
                const SizedBox(height: 14),
                _buildMenuCard(
                  context,
                  title: "Talk to HOPE",
                  subtitle: "Initialize neural chat relay with HOPE AI",
                  icon: Icons.terminal_rounded,
                  destinationPage: const ChatScreen(),
                  isAssessment: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Custom Glassmorphic Operational Selection Tile
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget destinationPage,
    required bool isAssessment,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF09090A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (isAssessment) {
              final dynamic result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destinationPage),
              );

              if (result != null && result is String) {
                setState(() {
                  _assessmentResult = result;
                });
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destinationPage),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.03)),
                  ),
                  child: Icon(icon, color: kPrimaryAccent, size: 22),
                ),
                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.15),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

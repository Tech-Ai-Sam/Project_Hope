// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_hope/Features/assesment/screens/portal_screen.dart';
import 'package:project_hope/main.dart';
import 'package:project_hope/view/settingscreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  StreamSubscription<User?>? _authListener;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;

    _authListener = _auth.userChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  @override
  void dispose() {
    _authListener?.cancel();
    super.dispose();
  }

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(
      text: _currentUser?.displayName,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF09090A),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 28,
          right: 28,
          top: 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "UPDATE SANCTUARY IDENTITY",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: kPrimaryAccent,
              decoration: InputDecoration(
                hintText: "Enter cryptographic display name",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.15),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.black,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.03)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: kPrimaryAccent.withOpacity(0.4),
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await _currentUser?.updateDisplayName(newName);
                    await _currentUser?.reload();
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    debugPrint("Identity sync failure: $e");
                  }
                }
              },
              child: const Text(
                "COMMIT CHANGES",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
        _currentUser?.displayName == null || _currentUser!.displayName!.isEmpty
        ? "Sanctuary Seeker"
        : _currentUser!.displayName!;
    final String email = _currentUser?.email ?? "seeker@projecthope.com";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              "MY SANCTUARY",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "SEEKER ENVIRONMENT INDEX",
              style: TextStyle(
                color: kPrimaryAccent.withOpacity(0.4),
                fontSize: 8,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PROFILE AVATAR BLOCK ---
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kPrimaryAccent.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: const Color(0xFF09090A),
                      child: Text(
                        displayName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- METRICS ---
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    "Sanctuary Streak",
                    "7 Days",
                    Icons.local_fire_department_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    "Beats Session",
                    "12 Hrs",
                    Icons.graphic_eq_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- PROFILE MANAGEMENT ---
            _buildSectionLabel("IDENTITY & METRICS"),
            const SizedBox(height: 12),

            _buildMenuTile(
              "Edit Identity Name",
              Icons.person_outline_rounded,
              _showEditProfileDialog,
            ),
            _buildMenuTile(
              "Take Well-being Assessments",
              Icons.analytics_outlined,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssessmentPortalScreen(),
                  ),
                );
              },
              iconColor: kPrimaryAccent,
            ),
            const SizedBox(height: 28),

            // --- SYSTEM HOOKS ---
            _buildSectionLabel("PREFERENCES & HARDWARE"),
            const SizedBox(height: 12),

            _buildMenuTile("App Settings", Icons.settings_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF09090A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimaryAccent.withOpacity(0.8), size: 20),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          color: kPrimaryAccent.withOpacity(0.4),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    String title,
    IconData leadingIcon,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF09090A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Icon(
          leadingIcon,
          color: iconColor ?? Colors.white.withOpacity(0.4),
          size: 18,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white.withOpacity(0.15),
          size: 12,
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import 'package:project_hope/main.dart';
import 'package:project_hope/view/loginpage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _notificationsEnabled = true;
  bool _isNatureSoundsEnabled = true;
  bool _isAmbientBeatsEnabled = false;
  bool _isSettingsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllConfigurations();
  }

  Future<void> _loadAllConfigurations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _isNatureSoundsEnabled = prefs.getBool('nature_sounds_enabled') ?? true;
        _isAmbientBeatsEnabled =
            prefs.getBool('ambient_beats_enabled') ?? false;
        _isSettingsLoading = false;
      });
    } catch (e) {
      setState(() => _isSettingsLoading = false);
    }
  }

  Future<void> _updatePrefFlag(
    String key,
    bool value,
    Function(bool) updateState,
  ) async {
    updateState(value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint("Failed to update disk config state: $e");
    }
  }

  Future<void> _clearAppStateCache() async {
    final bool? confirmWipe = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF09090A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.03), width: 1),
        ),
        title: const Text(
          "RESET APP DATA?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            "This action will completely erase your local configurations and offline chat cache with HOPE AI. This deployment modification is permanent.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "CANCEL",
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.redAccent.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "CLEAR EVERYTHING",
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmWipe == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _loadAllConfigurations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "All local cache data cleared.",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            backgroundColor: kPrimaryAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              "SETTINGS",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "SYSTEM CONFIGURATION PANEL",
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white70,
            size: 16,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isSettingsLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: kPrimaryAccent,
                strokeWidth: 2,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PREFERENCES SECTION ---
                  _buildSectionHeader("GLOBAL PREFERENCES"),
                  const SizedBox(height: 12),

                  _buildSettingTile(
                    icon: Icons.notifications_none_outlined,
                    title: "Push Notifications",
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeColor: kPrimaryAccent,
                      activeTrackColor: kPrimaryAccent.withOpacity(0.15),
                      inactiveThumbColor: Colors.white.withOpacity(0.2),
                      inactiveTrackColor: Colors.white.withOpacity(0.05),
                      onChanged: (val) => _updatePrefFlag(
                        'notifications_enabled',
                        val,
                        (v) => setState(() => _notificationsEnabled = v),
                      ),
                    ),
                  ),

                  _buildSettingTile(
                    icon: Icons.notifications_active_outlined,
                    title: "System OS Permissions",
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.15),
                      size: 12,
                    ),
                    onTap: () => AppSettings.openAppSettings(
                      type: AppSettingsType.notification,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- AMBIENT AUDIO SECTION ---
                  _buildSectionHeader("AMBIENT SOUNDSCAPES"),
                  const SizedBox(height: 12),

                  _buildSettingTile(
                    icon: Icons.waves_rounded,
                    title: "Calming Nature Audio",
                    trailing: Switch(
                      value: _isNatureSoundsEnabled,
                      activeColor: kPrimaryAccent,
                      activeTrackColor: kPrimaryAccent.withOpacity(0.15),
                      inactiveThumbColor: Colors.white.withOpacity(0.2),
                      inactiveTrackColor: Colors.white.withOpacity(0.05),
                      onChanged: (val) => _updatePrefFlag(
                        'nature_sounds_enabled',
                        val,
                        (v) => setState(() => _isNatureSoundsEnabled = v),
                      ),
                    ),
                  ),

                  _buildSettingTile(
                    icon: Icons.graphic_eq_rounded,
                    title: "Lo-Fi Binaural Beats",
                    trailing: Switch(
                      value: _isAmbientBeatsEnabled,
                      activeColor: kPrimaryAccent,
                      activeTrackColor: kPrimaryAccent.withOpacity(0.15),
                      inactiveThumbColor: Colors.white.withOpacity(0.2),
                      inactiveTrackColor: Colors.white.withOpacity(0.05),
                      onChanged: (val) => _updatePrefFlag(
                        'ambient_beats_enabled',
                        val,
                        (v) => setState(() => _isAmbientBeatsEnabled = v),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- SYSTEM & RECOVERY ---
                  _buildSectionHeader("SYSTEM & DATA"),
                  const SizedBox(height: 12),

                  _buildSettingTile(
                    icon: Icons.delete_forever_outlined,
                    title: "Clear Chat Cache",
                    trailing: Icon(
                      Icons.cleaning_services_outlined,
                      color: Colors.white.withOpacity(0.2),
                      size: 14,
                    ),
                    onTap: _clearAppStateCache,
                  ),

                  _buildSettingTile(
                    icon: Icons.info_outline,
                    title: "App Version",
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Text(
                        "2.7.3",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // --- SECURE LOGOUT ---
                  ElevatedButton.icon(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF09090A),
                      foregroundColor: Colors.redAccent,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.redAccent.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: const Text(
                      "LOG OUT FROM SANCTUARY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: kPrimaryAccent.withOpacity(0.4),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: Colors.white.withOpacity(0.4), size: 18),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}

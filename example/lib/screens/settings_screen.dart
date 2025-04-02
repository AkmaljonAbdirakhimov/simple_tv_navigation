import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingItem(
              id: "setting-account",
              icon: Icons.person,
              title: "Account",
              color: Colors.blue,
              leftId: "nav-settings",
              downId: "setting-appearance",
            ),
            const Divider(color: Colors.grey),
            _buildSettingItem(
              id: "setting-appearance",
              icon: Icons.color_lens,
              title: "Appearance",
              color: Colors.purple,
              leftId: "nav-settings",
              upId: "setting-account",
              downId: "setting-notifications",
            ),
            const Divider(color: Colors.grey),
            _buildSettingItem(
              id: "setting-notifications",
              icon: Icons.notifications,
              title: "Notifications",
              color: Colors.orange,
              leftId: "nav-settings",
              upId: "setting-appearance",
              downId: "setting-privacy",
            ),
            const Divider(color: Colors.grey),
            _buildSettingItem(
              id: "setting-privacy",
              icon: Icons.lock,
              title: "Privacy & Security",
              color: Colors.green,
              leftId: "nav-settings",
              upId: "setting-notifications",
              downId: "setting-about",
            ),
            const Divider(color: Colors.grey),
            _buildSettingItem(
              id: "setting-about",
              icon: Icons.info,
              title: "About",
              color: Colors.grey,
              leftId: "nav-settings",
              upId: "setting-privacy",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String id,
    required IconData icon,
    required String title,
    required Color color,
    String? leftId,
    String? rightId,
    String? upId,
    String? downId,
  }) {
    return TVFocusable(
      id: id,
      leftId: leftId,
      rightId: rightId,
      upId: upId,
      downId: downId,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

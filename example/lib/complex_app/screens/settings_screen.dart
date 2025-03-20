import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Settings sections
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Account',
                    items: [
                      _buildSettingItem(
                        id: 'settings_profile',
                        title: 'Profile',
                        icon: Icons.person,
                        onSelect: () => _showSnackBar(context, 'Profile'),
                      ),
                      _buildSettingItem(
                        id: 'settings_subscription',
                        title: 'Subscription',
                        icon: Icons.card_membership,
                        onSelect: () => _showSnackBar(context, 'Subscription'),
                      ),
                      _buildSettingItem(
                        id: 'settings_payment',
                        title: 'Payment Methods',
                        icon: Icons.payment,
                        onSelect: () =>
                            _showSnackBar(context, 'Payment Methods'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSection(
                    title: 'Preferences',
                    items: [
                      _buildSettingItem(
                        id: 'settings_language',
                        title: 'Language',
                        icon: Icons.language,
                        onSelect: () => _showSnackBar(context, 'Language'),
                      ),
                      _buildSettingItem(
                        id: 'settings_quality',
                        title: 'Video Quality',
                        icon: Icons.high_quality,
                        onSelect: () => _showSnackBar(context, 'Video Quality'),
                      ),
                      _buildSettingItem(
                        id: 'settings_subtitles',
                        title: 'Subtitles',
                        icon: Icons.subtitles,
                        onSelect: () => _showSnackBar(context, 'Subtitles'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSection(
                    title: 'System',
                    items: [
                      _buildSettingItem(
                        id: 'settings_notifications',
                        title: 'Notifications',
                        icon: Icons.notifications,
                        onSelect: () => _showSnackBar(context, 'Notifications'),
                      ),
                      _buildSettingItem(
                        id: 'settings_storage',
                        title: 'Storage',
                        icon: Icons.storage,
                        onSelect: () => _showSnackBar(context, 'Storage'),
                      ),
                      _buildSettingItem(
                        id: 'settings_about',
                        title: 'About',
                        icon: Icons.info,
                        onSelect: () => _showSnackBar(context, 'About'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildSettingItem({
    required String id,
    required String title,
    required IconData icon,
    required VoidCallback onSelect,
  }) {
    return TVFocusable(
      id: id,
      onSelect: onSelect,
      focusBuilder: (context, isFocused, isSelected, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                isFocused ? Colors.blue.withOpacity(0.3) : Colors.transparent,
            border: Border.all(
              color: isFocused ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected $message')),
    );
  }
}

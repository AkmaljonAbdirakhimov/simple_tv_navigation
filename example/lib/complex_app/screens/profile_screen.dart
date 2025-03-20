import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              'Profile',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Profile content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile avatar and info
              Expanded(
                flex: 2,
                child: _buildProfileInfo(context),
              ),

              // Actions menu
              Expanded(
                flex: 3,
                child: _buildActionMenu(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    return Column(
      children: [
        // Avatar
        TVFocusable(
          id: 'profile_avatar',
          rightId: 'profile_edit',
          downId: 'profile_subscription',
          leftId: 'sidebar_profile',
          focusBuilder: (context, isFocused, isSelected, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFocused ? Colors.blue : Colors.transparent,
                  width: 4,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.6),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          onSelect: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Change profile picture')),
            );
          },
          child: Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 80,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Name
        const Text(
          'John Doe',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        // Email
        const Text(
          'john.doe@example.com',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 32),

        // Subscription badge
        TVFocusable(
          id: 'profile_subscription',
          upId: 'profile_avatar',
          rightId: 'profile_watch_history',
          focusBuilder: (context, isFocused, isSelected, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFocused ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: child,
            );
          },
          onSelect: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('View subscription details')),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber[800],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.star, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Premium Member',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionButton(
            id: 'profile_edit',
            title: 'Edit Profile',
            icon: Icons.edit,
            leftId: 'profile_avatar',
            downId: 'profile_watch_history',
            onSelect: () => _showSnackBar(context, 'Edit Profile'),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            id: 'profile_watch_history',
            title: 'Watch History',
            icon: Icons.history,
            leftId: 'profile_subscription',
            upId: 'profile_edit',
            downId: 'profile_favorites',
            onSelect: () => _showSnackBar(context, 'Watch History'),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            id: 'profile_favorites',
            title: 'Favorites',
            icon: Icons.favorite,
            upId: 'profile_watch_history',
            downId: 'profile_settings',
            onSelect: () => _showSnackBar(context, 'Favorites'),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            id: 'profile_settings',
            title: 'Account Settings',
            icon: Icons.settings,
            upId: 'profile_favorites',
            downId: 'profile_logout',
            onSelect: () => _showSnackBar(context, 'Account Settings'),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            id: 'profile_logout',
            title: 'Logout',
            icon: Icons.exit_to_app,
            upId: 'profile_settings',
            onSelect: () => _showSnackBar(context, 'Logout'),
            color: Colors.red.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String id,
    required String title,
    required IconData icon,
    required VoidCallback onSelect,
    Color? color,
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
      onSelect: onSelect,
      focusBuilder: (context, isFocused, isSelected, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color ?? const Color(0xFF1C2431),
          borderRadius: BorderRadius.circular(8),
        ),
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
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected $message')),
    );
  }
}

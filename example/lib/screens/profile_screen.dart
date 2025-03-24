import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, dynamic> _userProfile = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'plan': 'Premium',
    'avatar': Icons.person,
    'avatarColor': Colors.blue,
    'memberSince': 'March 2022',
  };

  final List<Map<String, dynamic>> _settings = [
    {
      'icon': Icons.language,
      'title': 'Language',
      'value': 'English',
      'options': ['English', 'Spanish', 'French', 'German', 'Japanese'],
    },
    {
      'icon': Icons.dark_mode,
      'title': 'Theme',
      'value': 'Dark',
      'options': ['Light', 'Dark', 'System'],
    },
    {
      'icon': Icons.hd,
      'title': 'Video Quality',
      'value': '4K',
      'options': ['Auto', '720p', '1080p', '4K'],
    },
    {
      'icon': Icons.subtitles,
      'title': 'Subtitles',
      'value': 'On',
      'options': ['Off', 'On'],
    },
    {
      'icon': Icons.notifications,
      'title': 'Notifications',
      'value': 'All',
      'options': ['All', 'Important Only', 'None'],
    },
    {
      'icon': Icons.lock,
      'title': 'Parental Controls',
      'value': 'Off',
      'options': ['Off', 'On'],
    },
  ];

  final List<Map<String, dynamic>> _accountOptions = [
    {
      'icon': Icons.wallet,
      'title': 'Billing',
      'description': 'Manage your subscription and payment methods',
    },
    {
      'icon': Icons.history,
      'title': 'Viewing History',
      'description': 'See what you\'ve watched recently',
    },
    {
      'icon': Icons.devices,
      'title': 'Devices',
      'description': 'Manage connected devices',
    },
    {
      'icon': Icons.help,
      'title': 'Help & Support',
      'description': 'Get assistance with any issues',
    },
    {
      'icon': Icons.logout,
      'title': 'Log Out',
      'description': 'Sign out of your account',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildProfileHeader(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildSettings(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildAccountOptions(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 50),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TVFocusable(
            id: 'profile_avatar',
            leftId: 'sidebar_profile',
            downId: 'setting_0',
            onSelect: () => _editProfile(),
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
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: child,
              );
            },
            child: CircleAvatar(
              radius: 50,
              backgroundColor: _userProfile['avatarColor'],
              child: Icon(
                _userProfile['avatar'],
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _userProfile['name'],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userProfile['email'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.blue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _userProfile['plan'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Member since ${_userProfile['memberSince']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Column(
      children: List.generate(_settings.length, (index) {
        return TVFocusable(
          id: 'setting_$index',
          leftId: 'sidebar_profile',
          upId: index == 0 ? 'profile_avatar' : 'setting_${index - 1}',
          downId: index == _settings.length - 1
              ? 'account_0'
              : 'setting_${index + 1}',
          onSelect: () => _changeSetting(index),
          focusBuilder: (context, isFocused, isSelected, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
              decoration: BoxDecoration(
                color: isFocused
                    ? Colors.grey[800]
                    : Colors.grey[900]!.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFocused ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  _settings[index]['icon'],
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _settings[index]['title'],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _settings[index]['value'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAccountOptions() {
    return Column(
      children: List.generate(_accountOptions.length, (index) {
        return TVFocusable(
          id: 'account_$index',
          leftId: 'sidebar_profile',
          upId: index == 0
              ? 'setting_${_settings.length - 1}'
              : 'account_${index - 1}',
          downId: index == _accountOptions.length - 1
              ? null
              : 'account_${index + 1}',
          onSelect: () => _selectAccountOption(index),
          focusBuilder: (context, isFocused, isSelected, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
              decoration: BoxDecoration(
                color: isFocused
                    ? Colors.grey[800]
                    : Colors.grey[900]!.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFocused ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  _accountOptions[index]['icon'],
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _accountOptions[index]['title'],
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _accountOptions[index]['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit Profile clicked'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _changeSetting(int index) {
    final setting = _settings[index];
    final options = setting['options'] as List<String>;
    final currentValueIndex = options.indexOf(setting['value']);
    final nextValueIndex = (currentValueIndex + 1) % options.length;

    setState(() {
      _settings[index]['value'] = options[nextValueIndex];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${setting['title']} changed to ${options[nextValueIndex]}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _selectAccountOption(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_accountOptions[index]['title']} selected'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

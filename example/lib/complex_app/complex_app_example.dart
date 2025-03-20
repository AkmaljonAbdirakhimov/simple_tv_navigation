import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

import 'screens/home_screen.dart';
import 'screens/cinema_screen.dart';
import 'screens/online_tv_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/debug_focusable.dart';

// Global debug toggle
class DebugSettings {
  static bool showDebugOverlay = true;

  static void toggleDebugOverlay() {
    showDebugOverlay = !showDebugOverlay;
  }
}

void main() {
  runApp(const ComplexAppExample());
}

class ComplexAppExample extends StatelessWidget {
  const ComplexAppExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TVNavigationProvider(
      child: const ComplexAppLayout(),
    );
  }
}

class ComplexAppLayout extends StatefulWidget {
  const ComplexAppLayout({super.key});

  @override
  State<ComplexAppLayout> createState() => _ComplexAppLayoutState();
}

class _ComplexAppLayoutState extends State<ComplexAppLayout> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _screens = [
    {
      'title': 'Home',
      'id': 'home',
      'screen': const HomeScreen(),
    },
    {
      'title': 'Cinema',
      'id': 'cinema',
      'screen': const CinemaScreen(),
    },
    {
      'title': 'Online TV',
      'id': 'online_tv',
      'screen': const OnlineTvScreen(),
    },
    {
      'title': 'Profile',
      'id': 'profile',
      'screen': const ProfileScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: Colors.grey.shade900,
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TV App',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Debug toggle
                      IconButton(
                        icon: Icon(
                          Icons.bug_report,
                          color: DebugSettings.showDebugOverlay
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            DebugSettings.toggleDebugOverlay();
                          });
                        },
                        tooltip: 'Toggle Debug Overlay',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Navigation items
                ...List.generate(
                  _screens.length,
                  (index) => _buildSidebarItem(index),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _screens[_selectedIndex]['screen'],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    final isSelected = _selectedIndex == index;
    final screen = _screens[index];

    // Calculate navigation IDs
    String? upId = index > 0 ? 'sidebar_${_screens[index - 1]['id']}' : null;
    String? downId = index < _screens.length - 1
        ? 'sidebar_${_screens[index + 1]['id']}'
        : null;

    // Set the correct rightId based on the screen
    String? rightId;
    switch (screen['id']) {
      case 'home':
        rightId = 'home_banner_watch';
        break;
      case 'cinema':
        rightId = 'cinema_tab_0';
        break;
      case 'online_tv':
        rightId = 'tv_tab_0';
        break;
      case 'profile':
        rightId = 'profile_avatar';
        break;
      default:
        rightId = null;
    }

    return DebugFocusable(
      id: 'sidebar_${screen['id']}',
      upId: upId,
      downId: downId,
      rightId: rightId,
      autoFocus: index == 0,
      showDebugInfo: DebugSettings.showDebugOverlay,
      onSelect: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      focusBuilder: (context, isFocused, isSelected, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color:
                isFocused ? Colors.blue.withOpacity(0.3) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          Icon(
            _getIconForScreen(screen['id']),
            color: isSelected ? Colors.white : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            screen['title'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForScreen(String screenId) {
    switch (screenId) {
      case 'home':
        return Icons.home;
      case 'cinema':
        return Icons.movie;
      case 'online_tv':
        return Icons.tv;
      case 'profile':
        return Icons.person;
      default:
        return Icons.circle;
    }
  }
}

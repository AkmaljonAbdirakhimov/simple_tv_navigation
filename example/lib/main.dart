import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

// Import screens
import 'screens/home_screen.dart';
import 'screens/cinema_screen.dart';
import 'screens/tv_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1216),
        cardColor: const Color(0xFF1A1D22),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2196F3),
          secondary: Color(0xFF64B5F6),
          background: Color(0xFF0F1216),
          surface: Color(0xFF1A1D22),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onScreenChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TVNavigationProvider(
      initialFocusId: 'sidebar_home',
      child: Builder(builder: (context) {
        return Scaffold(
          body: Row(
            children: [
              // Sidebar
              SideBar(
                selectedIndex: _selectedIndex,
                onScreenChanged: _onScreenChanged,
              ),
              // Main content
              Expanded(
                child: _buildScreen(_selectedIndex),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const CinemaScreen();
      case 2:
        return const TVScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const Center(child: Text('Unknown Screen'));
    }
  }
}

class SideBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onScreenChanged;

  const SideBar({
    super.key,
    required this.selectedIndex,
    required this.onScreenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: const Color(0xFF1A1D22),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'TV Navigation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSidebarItem(
            context: context,
            index: 0,
            icon: Icons.home,
            title: 'Home',
            id: 'sidebar_home',
            downId: 'sidebar_cinema',
            rightId: 'home_banner_watch',
          ),
          _buildSidebarItem(
            context: context,
            index: 1,
            icon: Icons.movie,
            title: 'Cinema',
            id: 'sidebar_cinema',
            upId: 'sidebar_home',
            downId: 'sidebar_tv',
            rightId: 'cinema_tab_0',
          ),
          _buildSidebarItem(
            context: context,
            index: 2,
            icon: Icons.tv,
            title: 'Online TV',
            id: 'sidebar_tv',
            upId: 'sidebar_cinema',
            downId: 'sidebar_profile',
            rightId: 'channel_0',
          ),
          _buildSidebarItem(
            context: context,
            index: 3,
            icon: Icons.person,
            title: 'Profile',
            id: 'sidebar_profile',
            upId: 'sidebar_tv',
            rightId: 'profile_avatar',
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version ${DateTime.now().year}.${DateTime.now().month}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String title,
    required String id,
    String? upId,
    String? downId,
    String? leftId,
    String? rightId,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TVFocusable(
        id: id,
        upId: upId,
        downId: downId,
        leftId: leftId,
        rightId: rightId,
        onSelect: () {
          onScreenChanged(index);
        },
        focusBuilder: (context, isFocused, isSelected, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color:
                  isFocused ? Colors.blue.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
            border:
                isSelected ? Border.all(color: Colors.blue, width: 1) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.white,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

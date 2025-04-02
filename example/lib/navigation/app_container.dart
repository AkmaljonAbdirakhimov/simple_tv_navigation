import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/sidebar.dart';
import 'navigator_service.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  int _currentIndex = 0;

  // Keys for each screen container
  final List<GlobalKey<_ScreenContainerState>> _containerKeys = [
    GlobalKey<_ScreenContainerState>(),
    GlobalKey<_ScreenContainerState>(),
    GlobalKey<_ScreenContainerState>(),
  ];

  // Primary screens for the sidebar
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ScreenContainer(
        key: _containerKeys[0],
        initialRoute: const HomeScreen(),
      ),
      ScreenContainer(
        key: _containerKeys[1],
        initialRoute: const ProfileScreen(),
      ),
      ScreenContainer(
        key: _containerKeys[2],
        initialRoute: const SettingsScreen(),
      ),
    ];

    // Activate the initial navigator after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activateCurrentNavigator();
    });
  }

  @override
  void dispose() {
    // Make sure to unregister any nested navigators
    NavigatorService.unregisterNestedNavigatorKey();
    super.dispose();
  }

  void setCurrentIndex(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      // Schedule navigator activation after the build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _activateCurrentNavigator();
      });
    }
  }

  // Activate the current tab's navigator
  void _activateCurrentNavigator() {
    // First ensure all navigators are deactivated
    for (int i = 0; i < _containerKeys.length; i++) {
      if (i != _currentIndex) {
        final state = _containerKeys[i].currentState;
        if (state != null) {
          state.deactivateNavigator();
        }
      }
    }

    // Now activate the current one
    final containerState = _containerKeys[_currentIndex].currentState;
    if (containerState != null) {
      containerState.activateNavigator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Row(
        children: [
          // Sidebar
          SidebarContainer(
            currentIndex: _currentIndex,
            onIndexChanged: setCurrentIndex,
          ),

          // Main content with IndexedStack
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable screen container with nested navigator
class ScreenContainer extends StatefulWidget {
  final Widget initialRoute;

  const ScreenContainer({
    super.key,
    required this.initialRoute,
  });

  @override
  State<ScreenContainer> createState() => _ScreenContainerState();
}

class _ScreenContainerState extends State<ScreenContainer> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _isActive = false;

  @override
  void dispose() {
    // Only unregister if this navigator is currently active
    if (_isActive) {
      NavigatorService.unregisterNestedNavigatorKey();
    }
    super.dispose();
  }

  // Activate this navigator as the current one in NavigatorService
  void activateNavigator() {
    if (!_isActive) {
      _isActive = true;
      NavigatorService.registerNestedNavigatorKey(_navigatorKey);
    }
  }

  // Deactivate this navigator
  void deactivateNavigator() {
    if (_isActive) {
      _isActive = false;
      NavigatorService.unregisterNestedNavigatorKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => widget.initialRoute,
            settings: settings,
          );
        }
        // Return null to let the parent navigator handle other routes
        return null;
      },
    );
  }
}

// Sidebar container
class SidebarContainer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const SidebarContainer({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      color: Colors.black,
      child: Sidebar(
        currentIndex: currentIndex,
        onIndexChanged: onIndexChanged,
      ),
    );
  }
}

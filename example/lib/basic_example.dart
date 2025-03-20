import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

void main() {
  runApp(const BasicExampleApp());
}

class BasicExampleApp extends StatelessWidget {
  const BasicExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the entire screen in the TVNavigationProvider
    return TVNavigationProvider(
      // Set the initial focus ID (optional)
      initialFocusId: 'menu_home',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TV Navigation Example'),
        ),
        body: Row(
          children: [
            // Side menu
            SideMenu(),

            // Main content
            Expanded(
              child: ContentArea(),
            ),
          ],
        ),
        // Instructions for users
        bottomNavigationBar: Container(
          color: Colors.black12,
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Navigation: Arrow Keys | Select: Enter | Back: Escape',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'MENU',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Each menu item is a TVFocusable
          TVFocusable(
            id: 'menu_home',
            autoFocus: true,
            // Explicit navigation links
            rightId: 'content_item_1',
            downId: 'menu_movies',
            child: MenuItemWidget(
              icon: Icons.home,
              label: 'Home',
            ),
            onSelect: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Home selected')),
              );
            },
          ),
          const SizedBox(height: 8),
          TVFocusable(
            id: 'menu_movies',
            rightId: 'content_item_2',
            upId: 'menu_home',
            downId: 'menu_series',
            child: MenuItemWidget(
              icon: Icons.movie,
              label: 'Movies',
            ),
            onSelect: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Movies selected')),
              );
            },
          ),
          const SizedBox(height: 8),
          TVFocusable(
            id: 'menu_series',
            rightId: 'content_item_3',
            upId: 'menu_movies',
            downId: 'menu_settings',
            child: MenuItemWidget(
              icon: Icons.tv,
              label: 'TV Series',
            ),
            onSelect: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('TV Series selected')),
              );
            },
          ),
          const SizedBox(height: 8),
          TVFocusable(
            id: 'menu_settings',
            rightId: 'content_item_4',
            upId: 'menu_series',
            child: MenuItemWidget(
              icon: Icons.settings,
              label: 'Settings',
            ),
            onSelect: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings selected')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuItemWidget({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class ContentArea extends StatelessWidget {
  const ContentArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Content',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                // Content items with explicit navigation connections
                TVFocusable(
                  id: 'content_item_1',
                  leftId: 'menu_home',
                  rightId: 'content_item_2',
                  downId: 'content_item_3',
                  child: ContentItemWidget(
                    color: Colors.red,
                    title: 'Item 1',
                  ),
                  // Custom focus builder for different appearance when focused
                  focusBuilder: (context, isFocused, isSelected, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transformAlignment: Alignment.center,
                      transform: isFocused
                          ? (Matrix4.identity()..scale(1.05))
                          : Matrix4.identity(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.6),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: child,
                    );
                  },
                  onSelect: () => _showContentDetails(context, 'Item 1'),
                ),
                TVFocusable(
                  id: 'content_item_2',
                  leftId: 'content_item_1',
                  upId: 'menu_movies',
                  downId: 'content_item_4',
                  child: ContentItemWidget(
                    color: Colors.green,
                    title: 'Item 2',
                  ),
                  onSelect: () => _showContentDetails(context, 'Item 2'),
                ),
                TVFocusable(
                  id: 'content_item_3',
                  leftId: 'menu_series',
                  rightId: 'content_item_4',
                  upId: 'content_item_1',
                  child: ContentItemWidget(
                    color: Colors.orange,
                    title: 'Item 3',
                  ),
                  onSelect: () => _showContentDetails(context, 'Item 3'),
                ),
                TVFocusable(
                  id: 'content_item_4',
                  leftId: 'content_item_3',
                  upId: 'content_item_2',
                  downId: 'content_item_5',
                  child: ContentItemWidget(
                    color: Colors.purple,
                    title: 'Item 4',
                  ),
                  onSelect: () => _showContentDetails(context, 'Item 4'),
                ),
                TVFocusable(
                  id: 'content_item_5',
                  leftId: 'menu_settings',
                  upId: 'content_item_4',
                  rightId: 'content_item_6',
                  child: ContentItemWidget(
                    color: Colors.teal,
                    title: 'Item 5',
                  ),
                  onSelect: () => _showContentDetails(context, 'Item 5'),
                ),
                TVFocusable(
                  id: 'content_item_6',
                  leftId: 'content_item_5',
                  upId: 'content_item_4',
                  child: ContentItemWidget(
                    color: Colors.indigo,
                    title: 'Item 6',
                  ),
                  onSelect: () => _showContentDetails(context, 'Item 6'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContentDetails(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Create a nested navigation context in the dialog
        return TVNavigationProvider(
          // We need a new provider here to handle dialog navigation separately
          initialFocusId: 'dialog_watch',
          child: AlertDialog(
            title: Text('$title Details'),
            content: const SizedBox(
              height: 120,
              child: Text('This is a detailed description of the content item. '
                  'In a real application, this would show more information '
                  'about the movie, show, or other content.'),
            ),
            actions: [
              // Actions are focusable too
              TVFocusable(
                id: 'dialog_watch',
                rightId: 'dialog_close',
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Watching $title')),
                    );
                  },
                  child: const Text('Watch Now'),
                ),
              ),
              TVFocusable(
                id: 'dialog_close',
                leftId: 'dialog_watch',
                child: TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ContentItemWidget extends StatelessWidget {
  final Color color;
  final String title;

  const ContentItemWidget({
    super.key,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

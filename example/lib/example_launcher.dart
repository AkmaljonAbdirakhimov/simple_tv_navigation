import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';
import 'basic_example.dart' as basic;
import 'advanced_example.dart' as advanced;

void main() {
  runApp(const ExampleLauncherApp());
}

class ExampleLauncherApp extends StatelessWidget {
  const ExampleLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Navigation Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleLauncherScreen(),
    );
  }
}

class ExampleLauncherScreen extends StatelessWidget {
  const ExampleLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TVNavigationProvider(
      initialFocusId: 'basic',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TV Navigation Examples'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select an example:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TVFocusable(
                    autoFocus: true,
                    id: 'basic',
                    rightId: 'advanced',
                    focusBuilder: _focusBuilder,
                    onSelect: () => _openExample(context, 'basic'),
                    child: _ExampleButton(
                      title: 'Basic Example',
                      description: 'Simple navigation with content grid',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 24),
                  TVFocusable(
                    id: 'advanced',
                    leftId: 'basic',
                    focusBuilder: _focusBuilder,
                    onSelect: () => _openExample(context, 'advanced'),
                    child: _ExampleButton(
                      title: 'Advanced Example',
                      description: 'With navigation visualization',
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Navigate using arrow keys and Enter/Return',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _focusBuilder(
      BuildContext context, bool isFocused, bool isSelected, Widget child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transformAlignment: Alignment.center,
      transform:
          isFocused ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
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
  }

  void _openExample(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (type) {
            case 'basic':
              return const basic.BasicExampleApp();
            case 'advanced':
              return const advanced.AdvancedExampleApp();
            default:
              return const Scaffold(
                body: Center(child: Text('Unknown example type')),
              );
          }
        },
      ),
    );
  }
}

class _ExampleButton extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const _ExampleButton({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

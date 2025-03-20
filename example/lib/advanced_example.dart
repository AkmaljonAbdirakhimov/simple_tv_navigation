import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';
import 'dart:math' as math;

/// Advanced example showing a complex TV navigation system with visualization
/// This example demonstrates:
/// 1. Complex multi-directional navigation
/// 2. Visual representation of navigation links
/// 3. Nested navigation contexts
/// 4. Custom focus effects
/// 5. Navigation analysis
void main() {
  runApp(const AdvancedExampleApp());
}

class AdvancedExampleApp extends StatelessWidget {
  const AdvancedExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced TV Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const NavigationDemoScreen(),
    );
  }
}

class NavigationDemoScreen extends StatefulWidget {
  const NavigationDemoScreen({super.key});

  @override
  State<NavigationDemoScreen> createState() => _NavigationDemoScreenState();
}

class _NavigationDemoScreenState extends State<NavigationDemoScreen> {
  bool _showNavigationLinks = true;
  bool _showNavigationAnalysis = false;
  List<String> _navigationIssues = [];

  @override
  Widget build(BuildContext context) {
    return TVNavigationProvider(
      initialFocusId: 'menu_item_1',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Navigation Demo'),
        ),
        body: Builder(builder: (context) {
          return Column(
            children: [
              // Controls
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    TVFocusable(
                      id: 'toggle_links',
                      rightId: 'analyze_navigation',
                      downId: 'menu_item_1',
                      child: ElevatedButton.icon(
                        icon: Icon(_showNavigationLinks
                            ? Icons.visibility_off
                            : Icons.visibility),
                        label: Text(_showNavigationLinks
                            ? 'Hide Navigation Links'
                            : 'Show Navigation Links'),
                        onPressed: () {},
                      ),
                      onSelect: () {
                        setState(() {
                          _showNavigationLinks = !_showNavigationLinks;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    TVFocusable(
                      id: 'analyze_navigation',
                      leftId: 'toggle_links',
                      downId: 'menu_item_2',
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.analytics),
                        label: const Text('Analyze Navigation'),
                        onPressed: () {},
                      ),
                      onSelect: () {
                        _analyzeNavigation(context);
                      },
                    ),
                  ],
                ),
              ),

              if (_showNavigationAnalysis && _navigationIssues.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Navigation Issues Detected:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_navigationIssues.map((issue) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.warning,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(issue)),
                              ],
                            ),
                          ))),
                    ],
                  ),
                ),

              // Main content with navigation visualization
              Expanded(
                child: Stack(
                  children: [
                    // Background grid
                    CustomPaint(
                      painter: GridPainter(),
                      size: Size.infinite,
                    ),

                    // Navigation links layer
                    if (_showNavigationLinks) NavigationLinksLayer(),

                    // Actual navigation elements
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            NavigableTile(
                              id: 'menu_item_1',
                              autoFocus: true,
                              upId: 'toggle_links',
                              rightId: 'menu_item_2',
                              downId: 'content_1',
                              label: 'Menu 1',
                              color: Colors.blue,
                            ),
                            NavigableTile(
                              id: 'menu_item_2',
                              upId: 'analyze_navigation',
                              leftId: 'menu_item_1',
                              rightId: 'menu_item_3',
                              downId: 'content_2',
                              label: 'Menu 2',
                              color: Colors.green,
                            ),
                            NavigableTile(
                              id: 'menu_item_3',
                              leftId: 'menu_item_2',
                              rightId: 'menu_item_4',
                              downId: 'content_3',
                              label: 'Menu 3',
                              color: Colors.orange,
                            ),
                            NavigableTile(
                              id: 'menu_item_4',
                              leftId: 'menu_item_3',
                              downId: 'content_4',
                              label: 'Menu 4',
                              color: Colors.purple,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            NavigableTile(
                              id: 'content_1',
                              upId: 'menu_item_1',
                              rightId: 'content_2',
                              downId: 'subcontent_1',
                              label: 'Content 1',
                              color: Colors.blue.shade700,
                              size: 100,
                            ),
                            NavigableTile(
                              id: 'content_2',
                              upId: 'menu_item_2',
                              leftId: 'content_1',
                              rightId: 'content_3',
                              downId: 'subcontent_2',
                              label: 'Content 2',
                              color: Colors.green.shade700,
                              size: 100,
                            ),
                            NavigableTile(
                              id: 'content_3',
                              upId: 'menu_item_3',
                              leftId: 'content_2',
                              rightId: 'content_4',
                              downId: 'subcontent_3',
                              label: 'Content 3',
                              color: Colors.orange.shade700,
                              size: 100,
                            ),
                            NavigableTile(
                              id: 'content_4',
                              upId: 'menu_item_4',
                              leftId: 'content_3',
                              // Deliberate navigation issue: no down connection
                              label: 'Content 4',
                              color: Colors.purple.shade700,
                              size: 100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            NavigableTile(
                              id: 'subcontent_1',
                              upId: 'content_1',
                              rightId: 'subcontent_2',
                              label: 'Sub 1',
                              color: Colors.blue.shade900,
                              size: 70,
                            ),
                            NavigableTile(
                              id: 'subcontent_2',
                              upId: 'content_2',
                              leftId: 'subcontent_1',
                              rightId: 'subcontent_3',
                              label: 'Sub 2',
                              color: Colors.green.shade900,
                              size: 70,
                            ),
                            NavigableTile(
                              id: 'subcontent_3',
                              upId: 'content_3',
                              leftId: 'subcontent_2',
                              // Deliberate navigation issue: wrong ID
                              rightId: 'non_existent_item',
                              label: 'Sub 3',
                              color: Colors.orange.shade900,
                              size: 70,
                            ),
                            // Deliberate unreachable element
                            NavigableTile(
                              id: 'unreachable',
                              label: 'Unreachable',
                              color: Colors.red.shade900,
                              size: 70,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        bottomNavigationBar: Container(
          color: Colors.indigo.shade800,
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Navigation: Arrow Keys | Select: Enter | Back: Escape',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _analyzeNavigation(BuildContext context) {
    // Get the navigation state through finding the element
    // For simplicity in this example, we'll just analyze the elements we manually added
    final elementIds = [
      'menu_item_1',
      'menu_item_2',
      'menu_item_3',
      'menu_item_4',
      'content_1',
      'content_2',
      'content_3',
      'content_4',
      'subcontent_1',
      'subcontent_2',
      'subcontent_3',
      'unreachable'
    ];

    final unreachable = <String>[];
    // Identify our unreachable element (which we deliberately added)
    unreachable.add('unreachable');

    final deadEnds = <String>[];
    // In our example, the bottom row items are dead-ends (no downward navigation)
    deadEnds.addAll(['subcontent_1', 'subcontent_2', 'subcontent_3']);

    final issues = <String>[];

    if (unreachable.isNotEmpty) {
      issues.add('Unreachable elements: ${unreachable.join(', ')}');
    }

    if (deadEnds.isNotEmpty) {
      issues.add('Dead-end elements: ${deadEnds.join(', ')}');
    }

    // Known broken connections in our example
    final brokenConnections = <String>[
      'subcontent_3 → right → non_existent_item',
    ];

    if (brokenConnections.isNotEmpty) {
      issues.add('Broken connections:');
      for (final connection in brokenConnections) {
        issues.add('  • $connection');
      }
    }

    setState(() {
      _navigationIssues = issues;
      _showNavigationAnalysis = true;
    });

    if (issues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No navigation issues found!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _showNavigationAnalysis = false;
      });
    }
  }
}

class NavigableTile extends StatelessWidget {
  final String id;
  final String? leftId;
  final String? rightId;
  final String? upId;
  final String? downId;
  final String label;
  final Color color;
  final double size;
  final bool autoFocus;

  const NavigableTile({
    super.key,
    required this.id,
    this.leftId,
    this.rightId,
    this.upId,
    this.downId,
    required this.label,
    required this.color,
    this.size = 80,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TVFocusable(
      id: id,
      autoFocus: autoFocus,
      leftId: leftId,
      rightId: rightId,
      upId: upId,
      downId: downId,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      focusBuilder: (context, isFocused, isSelected, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transformAlignment: Alignment.center,
          transform: isFocused
              ? (Matrix4.identity()..scale(1.15))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 3,
                    )
                  ]
                : null,
          ),
          child: child,
        );
      },
      onSelect: () {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text('Selected: $label'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: $id'),
                  const SizedBox(height: 8),
                  Text('Left: ${leftId ?? 'None'}'),
                  Text('Right: ${rightId ?? 'None'}'),
                  Text('Up: ${upId ?? 'None'}'),
                  Text('Down: ${downId ?? 'None'}'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Visualizes the navigation connections between elements
class NavigationLinksLayer extends StatelessWidget {
  const NavigationLinksLayer({super.key});

  @override
  Widget build(BuildContext context) {
    // For this example, we'll use a simplified approach without
    // depending on navigation state tracking
    return RepaintBoundary(
      child: CustomPaint(
        painter: SimplifiedNavigationLinksPainter(),
        size: Size.infinite,
      ),
    );
  }
}

/// Simplified painter that draws predefined connections
class SimplifiedNavigationLinksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // In a real implementation, this would use the actual elements and state
    // but for this example, we'll draw some representative connections

    // Draw horizontal connections
    _drawHorizontalConnections(canvas, size);

    // Draw vertical connections
    _drawVerticalConnections(canvas, size);

    // Draw some broken connections
    _drawBrokenConnections(canvas, size);
  }

  void _drawHorizontalConnections(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Top row connections
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.2),
      Offset(size.width * 0.75, size.height * 0.2),
      paint,
    );

    // Middle row connections
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.45),
      paint,
    );

    // Bottom row connections
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.7),
      paint,
    );
  }

  void _drawVerticalConnections(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw vertical connections (columns)
    for (var x = 0.25; x <= 0.75; x += 0.166) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.2),
        Offset(size.width * x, size.height * 0.7),
        paint,
      );
    }
  }

  void _drawBrokenConnections(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw a broken connection from the last item
    _drawDashedLine(
      canvas,
      Offset(size.width * 0.58, size.height * 0.7),
      Offset(size.width * 0.85, size.height * 0.7),
      dashPaint,
    );

    // Draw an X at the end
    const xSize = 6.0;
    final endPoint = Offset(size.width * 0.85, size.height * 0.7);
    canvas.drawLine(
      Offset(endPoint.dx - xSize, endPoint.dy - xSize),
      Offset(endPoint.dx + xSize, endPoint.dy + xSize),
      dashPaint,
    );
    canvas.drawLine(
      Offset(endPoint.dx - xSize, endPoint.dy + xSize),
      Offset(endPoint.dx + xSize, endPoint.dy - xSize),
      dashPaint,
    );

    // Draw a connection to the unreachable element
    _drawDashedLine(
      canvas,
      Offset(size.width * 0.85, size.height * 0.5),
      Offset(size.width * 0.85, size.height * 0.7),
      dashPaint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 5.0;
    const dashGap = 3.0;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final unitDx = dx / distance;
    final unitDy = dy / distance;

    var distanceSoFar = 0.0;
    var dashOn = true;

    while (distanceSoFar < distance) {
      final dashDistance = dashOn ? dashLength : dashGap;
      final remainingDistance = distance - distanceSoFar;
      final drawLength = math.min(dashDistance, remainingDistance);

      if (dashOn) {
        final dashStart = Offset(
          start.dx + unitDx * distanceSoFar,
          start.dy + unitDy * distanceSoFar,
        );
        final dashEnd = Offset(
          start.dx + unitDx * (distanceSoFar + drawLength),
          start.dy + unitDy * (distanceSoFar + drawLength),
        );
        canvas.drawLine(dashStart, dashEnd, paint);
      }

      distanceSoFar += drawLength;
      dashOn = !dashOn;
    }
  }

  @override
  bool shouldRepaint(SimplifiedNavigationLinksPainter oldDelegate) => false;
}

/// Painter for drawing a background grid
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    const double spacing = 40.0;

    // Draw horizontal lines
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}

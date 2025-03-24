import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  double _progress = 0.0;
  Timer? _timer;
  static const int _sliderDuration = 5; // seconds

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'The Matrix Resurrections',
      'icon': Icons.movie_creation,
      'color': Colors.green,
      'description':
          'Return to the world of two realities in this new chapter of the groundbreaking franchise.',
    },
    {
      'title': 'Dune',
      'icon': Icons.landscape,
      'color': Colors.amber,
      'description':
          'A mythic and emotionally charged hero\'s journey spanning desert planets.',
    },
    {
      'title': 'No Time To Die',
      'icon': Icons.local_police,
      'color': Colors.blueGrey,
      'description':
          'Bond has left active service. His peace is short-lived when his old friend Felix Leiter appears.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoplay();
  }

  @override
  void dispose() {
    _stopAutoplay();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoplay() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress +=
            1 / (_sliderDuration * 20); // Update progress 20 times per second
        if (_progress >= 1.0) {
          _progress = 0.0;
          final nextPage = (_currentPage + 1) % _banners.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  void _stopAutoplay() {
    _timer?.cancel();
    _timer = null;
  }

  void _resetProgress() {
    setState(() {
      _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildBanner(),
        ),
        SliverToBoxAdapter(
          child:
              _buildSection('Free Movies', _generateMovieItems('free'), 'free'),
        ),
        SliverToBoxAdapter(
          child: _buildSection('Top Movies', _generateMovieItems('top'), 'top'),
        ),
        SliverToBoxAdapter(
          child: _buildSection(
              'Featured Movies', _generateMovieItems('feat'), 'feat'),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Banner slider
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _banners.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                        _resetProgress();
                      });
                    },
                    itemBuilder: (context, index) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // Banner background with icon
                          Container(
                            color: Colors.grey[900],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _banners[index]['icon'],
                                  size: 120,
                                  color: _banners[index]['color'],
                                ),
                              ],
                            ),
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          // Content
                          Positioned(
                            left: 30,
                            bottom: 30,
                            right: 30,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _banners[index]['title'],
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _banners[index]['description'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Progress indicator at the top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[800],
                      color: Colors.blue,
                      minHeight: 3,
                    ),
                  ),

                  // Navigation indicators
                  Positioned(
                    bottom: 90,
                    right: 20,
                    child: Row(
                      children: List.generate(_banners.length, (index) {
                        return Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.blue
                                : Colors.white.withOpacity(0.4),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Action buttons (outside of PageView to avoid duplication)
                  Positioned(
                    left: 30,
                    bottom: 120,
                    right: 30,
                    child: Row(
                      children: [
                        TVFocusable(
                          id: 'home_banner_watch',
                          downId: 'free_0',
                          leftId: 'sidebar_home',
                          rightId: 'home_banner_like',
                          onSelect: () =>
                              _playMovie(_banners[_currentPage]['title']),
                          focusBuilder:
                              (context, isFocused, isSelected, child) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isFocused
                                    ? Colors.blue
                                    : Colors.blue.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: child,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.play_arrow),
                                SizedBox(width: 10),
                                Text('Watch Now'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TVFocusable(
                          id: 'home_banner_like',
                          downId: 'free_0',
                          leftId: 'home_banner_watch',
                          rightId: null,
                          onSelect: () =>
                              _likeMovie(_banners[_currentPage]['title']),
                          focusBuilder:
                              (context, isFocused, isSelected, child) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isFocused
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isFocused
                                      ? Colors.blue
                                      : Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: child,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.favorite_border),
                                SizedBox(width: 10),
                                Text('Add to Favorites'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<Map<String, dynamic>> items, String prefix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final String itemId = '${prefix}_$index';
              String? leftId =
                  index > 0 ? '${prefix}_${index - 1}' : 'sidebar_home';
              String? rightId =
                  index < items.length - 1 ? '${prefix}_${index + 1}' : null;

              // Connect first sections to banner buttons
              String? upId = prefix == 'free' &&
                      _currentPage >= 0 &&
                      _currentPage < _banners.length
                  ? 'home_banner_like'
                  : prefix == 'top'
                      ? 'free_$index'
                      : 'top_$index';

              // Connect to the next row or to nothing if it's the last row
              String? downId = prefix == 'free'
                  ? 'top_$index'
                  : prefix == 'top'
                      ? 'feat_$index'
                      : null;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TVFocusable(
                  id: itemId,
                  leftId: leftId,
                  rightId: rightId,
                  upId: upId,
                  downId: downId,
                  onSelect: () => _playMovie(items[index]['title']),
                  focusBuilder: (context, isFocused, isSelected, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      transform: isFocused
                          ? (Matrix4.identity()..translate(0.0, -10.0, 0.0))
                          : Matrix4.identity(),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  color: items[index]['color'],
                                  child: Center(
                                    child: Icon(
                                      items[index]['icon'],
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Gradient overlay for visibility
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.8),
                                      ],
                                      stops: const [0.7, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          items[index]['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index]['year'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Generate mock movie items
  List<Map<String, dynamic>> _generateMovieItems(String prefix) {
    final List<String> titles = [
      'Inception',
      'The Dark Knight',
      'Interstellar',
      'Tenet',
      'The Matrix',
      'Pulp Fiction',
      'Fight Club',
      'Forrest Gump',
      'The Godfather',
      'The Shawshank Redemption',
      'The Prestige',
      'Parasite'
    ];

    final List<String> years = ['2022', '2021', '2020', '2019', '2018', '2017'];

    final List<IconData> icons = [
      Icons.movie,
      Icons.theaters,
      Icons.videocam,
      Icons.camera_roll,
      Icons.video_library,
      Icons.local_movies,
      Icons.music_video,
      Icons.ondemand_video,
      Icons.movie_filter,
      Icons.video_label,
      Icons.slideshow,
      Icons.featured_video,
    ];

    final List<Color> colors = [
      Colors.red.shade800,
      Colors.blue.shade800,
      Colors.green.shade800,
      Colors.orange.shade800,
      Colors.purple.shade800,
      Colors.teal.shade800,
      Colors.indigo.shade800,
      Colors.pink.shade800,
      Colors.brown.shade800,
      Colors.cyan.shade800,
      Colors.deepOrange.shade800,
      Colors.deepPurple.shade800,
    ];

    return List.generate(
      10,
      (index) => {
        'title': titles[index % titles.length],
        'icon': icons[index % icons.length],
        'color': colors[index % colors.length],
        'year': years[index % years.length],
      },
    );
  }

  void _playMovie(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing $title')),
    );
  }

  void _likeMovie(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $title to favorites')),
    );
  }
}

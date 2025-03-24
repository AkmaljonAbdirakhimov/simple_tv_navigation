import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';
import 'package:provider/provider.dart';

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({super.key});

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Movies', 'Series', 'Cartoons'];
  int _currentTabIndex = 0;
  final Map<String, List<String>> _categories = {
    'Movies': ['Comedy', 'Drama', 'Hollywood'],
    'Series': ['Action', 'Thriller', 'Sci-Fi'],
    'Cartoons': ['Disney', 'Pixar', 'Anime'],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(0),
              _buildTabContent(1),
              _buildTabContent(2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_tabs.length, (index) {
          // Build navigation connections between tabs
          String? leftId =
              index > 0 ? 'cinema_tab_${index - 1}' : 'sidebar_cinema';
          String? rightId =
              index < _tabs.length - 1 ? 'cinema_tab_${index + 1}' : null;

          // Connect tabs to their first category
          String? downId = '${_tabs[index].toLowerCase()}_category_0';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TVFocusable(
              id: 'cinema_tab_$index',
              leftId: leftId,
              rightId: rightId,
              downId: downId,
              onSelect: () {
                _tabController.animateTo(index);
              },
              focusBuilder: (context, isFocused, isSelected, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isFocused
                        ? Colors.blue
                        : _currentTabIndex == index
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.transparent,
                    border: Border.all(
                      color: _currentTabIndex == index
                          ? Colors.blue
                          : Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color:
                        _currentTabIndex == index ? Colors.white : Colors.grey,
                    fontWeight: _currentTabIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    // Get categories for this tab type
    final categories = _categories[_tabs[tabIndex]] ?? [];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _tabs[tabIndex],
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ...List.generate(categories.length, (categoryIndex) {
          return SliverToBoxAdapter(
            child: _buildCategory(
              tabIndex,
              categoryIndex,
              categories[categoryIndex],
              _generateItems(),
            ),
          );
        }),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _buildCategory(int tabIndex, int categoryIndex, String categoryName,
      List<Map<String, dynamic>> items) {
    final tabPrefix = _tabs[tabIndex].toLowerCase();

    // Get all categories for this tab
    final List<String> categoriesForTab = _categories[_tabs[tabIndex]] ?? [];

    final categoryId = '${tabPrefix}_category_$categoryIndex';

    // Define navigation connections for category header
    String? categoryUpId;
    if (categoryIndex == 0) {
      // If it's the first category, connect up to the tab
      categoryUpId = 'cinema_tab_$tabIndex';
    } else {
      // Otherwise, connect to the first item of the previous category if it has items
      final previousCategoryName = categoriesForTab[categoryIndex - 1];

      // Generate items for the previous category to determine if it has any items
      final previousCategoryItems = _generateItems();

      // Connect to the first movie item in the previous category
      if (previousCategoryItems.isNotEmpty) {
        categoryUpId = '${tabPrefix}_${previousCategoryName.toLowerCase()}_0';
      } else {
        // If previous category has no items, fall back to its title
        categoryUpId = '${tabPrefix}_category_${categoryIndex - 1}';
      }
    }

    // Connect to first item in this category for down navigation if items exist
    // Otherwise, connect to the next category
    String? categoryDownId;
    if (items.isNotEmpty) {
      categoryDownId = '${tabPrefix}_${categoryName.toLowerCase()}_0';
    } else {
      categoryDownId = categoryIndex < categoriesForTab.length - 1
          ? '${tabPrefix}_category_${categoryIndex + 1}'
          : null;
    }

    // Connect category to first item in its row (for right navigation)
    String? categoryRightId = items.isNotEmpty
        ? '${tabPrefix}_${categoryName.toLowerCase()}_0'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 16),
          child: TVFocusable(
            id: categoryId,
            leftId: 'sidebar_cinema',
            rightId: categoryRightId,
            upId: categoryUpId,
            downId: categoryDownId,
            onSelect: () {
              // Focus the first item in this category
              if (categoryRightId != null) {
                final navigationState =
                    Provider.of<TVNavigationState>(context, listen: false);
                navigationState.setFocus(categoryRightId);
              }
            },
            focusBuilder: (context, isFocused, isSelected, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isFocused
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFocused ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: child,
              );
            },
            child: Text(
              categoryName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
              // Generate a unique ID for this item
              final itemId =
                  '${tabPrefix}_${categoryName.toLowerCase()}_$index';

              // Define navigation connections
              String? leftId = index > 0
                  ? '${tabPrefix}_${categoryName.toLowerCase()}_${index - 1}'
                  : categoryId; // Connect to category title when at first item

              String? rightId = index < items.length - 1
                  ? '${tabPrefix}_${categoryName.toLowerCase()}_${index + 1}'
                  : null;

              // Connect to category header above
              String? upId = categoryId;

              // Connect to next category title when pressing down, not directly to its items
              String? downId = null;
              if (categoryIndex < categoriesForTab.length - 1) {
                // Connect to the next category's title instead of directly to its item
                downId = '${tabPrefix}_category_${categoryIndex + 1}';
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TVFocusable(
                  id: itemId,
                  leftId: leftId,
                  rightId: rightId,
                  upId: upId,
                  downId: downId,
                  onSelect: () =>
                      _playItem(items[index]['title'], categoryName),
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
                                // Rating chip
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          items[index]['rating'].toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
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
                          '${items[index]['year']} · ${categoryName}',
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

  // Generate mock items for each category
  List<Map<String, dynamic>> _generateItems() {
    final List<String> movieTitles = [
      'The Godfather',
      'Pulp Fiction',
      'Fight Club',
      'The Dark Knight',
      'Goodfellas',
      'The Matrix',
      'Se7en',
      'City of God',
      'Interstellar',
      'Parasite',
    ];

    final List<String> seriesTitles = [
      'Breaking Bad',
      'Game of Thrones',
      'The Wire',
      'Stranger Things',
      'The Sopranos',
      'Chernobyl',
      'True Detective',
      'Fargo',
      'Westworld',
      'Narcos',
    ];

    final List<String> cartoonTitles = [
      'Toy Story',
      'Finding Nemo',
      'The Lion King',
      'Frozen',
      'Spirited Away',
      'Inside Out',
      'Coco',
      'Shrek',
      'Zootopia',
      'Up',
    ];

    final List<String> allTitles = [
      ...movieTitles,
      ...seriesTitles,
      ...cartoonTitles
    ];

    final List<IconData> icons = [
      Icons.movie,
      Icons.theaters,
      Icons.videocam,
      Icons.video_library,
      Icons.local_movies,
      Icons.music_video,
      Icons.ondemand_video,
      Icons.movie_filter,
      Icons.slideshow,
      Icons.featured_video,
      Icons.live_tv,
      Icons.personal_video,
      Icons.smart_display,
      Icons.subscriptions,
      Icons.video_call,
    ];

    final List<Color> colors = [
      Colors.red.shade700,
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.teal.shade700,
      Colors.indigo.shade700,
      Colors.pink.shade700,
      Colors.brown.shade700,
      Colors.cyan.shade700,
      Colors.amber.shade700,
      Colors.lime.shade700,
      Colors.deepOrange.shade700,
      Colors.lightBlue.shade700,
      Colors.deepPurple.shade700,
    ];

    final List<String> years = ['2023', '2022', '2021', '2020', '2019', '2018'];

    return List.generate(
      10,
      (index) => {
        'title': allTitles[index % allTitles.length],
        'icon': icons[index % icons.length],
        'color': colors[index % colors.length],
        'year': years[index % years.length],
        'rating': (3.5 + (index % 7) * 0.5).toStringAsFixed(1),
      },
    );
  }

  void _playItem(String title, String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing $title from $category')),
    );
  }
}

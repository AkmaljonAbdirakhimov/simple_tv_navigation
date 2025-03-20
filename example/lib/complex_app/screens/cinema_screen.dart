import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

import '../widgets/movie_card.dart';
import '../widgets/debug_focusable.dart';
import '../complex_app_example.dart';

class TabData {
  final String title;
  final String id;
  final List<CategoryData> categories;

  TabData({
    required this.title,
    required this.id,
    required this.categories,
  });
}

class CategoryData {
  final String name;
  final String id;
  final int itemCount;

  CategoryData({
    required this.name,
    required this.id,
    required this.itemCount,
  });

  String get fullId => '${id}_movies';
}

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({super.key});

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  final List<TabData> _tabsData = [
    TabData(
      title: 'Movies',
      id: 'movies',
      categories: [
        CategoryData(name: 'Comedy', id: 'comedy', itemCount: 10),
        CategoryData(name: 'Drama', id: 'drama', itemCount: 5),
        CategoryData(name: 'Hollywood', id: 'hollywood', itemCount: 8),
      ],
    ),
    TabData(
      title: 'Series',
      id: 'series',
      categories: [
        CategoryData(name: 'Comedy', id: 'series_comedy', itemCount: 7),
        CategoryData(name: 'Drama', id: 'series_drama', itemCount: 6),
        CategoryData(name: 'Hollywood', id: 'series_hollywood', itemCount: 9),
      ],
    ),
    TabData(
      title: 'Cartoons',
      id: 'cartoons',
      categories: [
        CategoryData(name: 'Anime', id: 'anime', itemCount: 5),
        CategoryData(name: 'Kids', id: 'kids', itemCount: 9),
        CategoryData(name: 'Adults', id: 'adults', itemCount: 6),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabsData.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Cinema',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: Row(
              children: List.generate(
                _tabsData.length,
                (index) => _buildTab(index),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: _buildTabContent(_selectedTab),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index) {
    final isSelected = _selectedTab == index;
    final tabData = _tabsData[index];
    final firstCategory = tabData.categories.first;
    final firstItemId = '${firstCategory.fullId}_0';

    return DebugFocusable(
      id: 'cinema_tab_$index',
      leftId: index > 0 ? 'cinema_tab_${index - 1}' : 'sidebar_cinema',
      rightId: index < _tabsData.length - 1 ? 'cinema_tab_${index + 1}' : null,
      downId: firstItemId,
      showDebugInfo: DebugSettings.showDebugOverlay,
      onSelect: () {
        setState(() {
          _selectedTab = index;
          _tabController.animateTo(index);
        });
      },
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Text(
            tabData.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    final tabData = _tabsData[tabIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        tabData.categories.length,
        (index) {
          final category = tabData.categories[index];
          final prevCategory = index > 0 ? tabData.categories[index - 1] : null;
          final nextCategory = index < tabData.categories.length - 1
              ? tabData.categories[index + 1]
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategorySection(
                title: category.name,
                category: category,
                prevCategory: prevCategory,
                nextCategory: nextCategory,
                tabId: tabData.id,
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _generateMockMovies(CategoryData category) {
    return List.generate(
      category.itemCount,
      (index) => {
        'id': '${category.fullId}_$index',
        'title': '${category.name} Movie ${index + 1}',
        'rating': (3 + (index % 3)) / 2 + 3,
      },
    );
  }

  Widget _buildCategorySection({
    required String title,
    required CategoryData category,
    required CategoryData? prevCategory,
    required CategoryData? nextCategory,
    required String tabId,
  }) {
    final movies = _generateMockMovies(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              final movieId = '${category.fullId}_$index';

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: MovieCard(
                  id: movieId,
                  title: movie['title'],
                  rating: movie['rating'],
                  leftId: index > 0 ? '${category.fullId}_${index - 1}' : null,
                  rightId: index < movies.length - 1
                      ? '${category.fullId}_${index + 1}'
                      : null,
                  upId: prevCategory != null
                      ? '${prevCategory.fullId}_${index < prevCategory.itemCount ? index : prevCategory.itemCount - 1}'
                      : 'cinema_tab_${_tabsData.indexWhere((tab) => tab.id == tabId)}',
                  downId: nextCategory != null && index < nextCategory.itemCount
                      ? '${nextCategory.fullId}_$index'
                      : null,
                  showDebugInfo: DebugSettings.showDebugOverlay,
                  onSelect: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected ${movie['title']}')));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

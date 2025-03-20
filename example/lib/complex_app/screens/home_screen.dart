import 'package:flutter/material.dart';

import '../widgets/movie_card.dart';
import '../widgets/debug_focusable.dart';
import '../complex_app_example.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Home',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Banner
          _buildBanner(context),

          const SizedBox(height: 32),

          // Categories
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMovieCategory(
                    title: 'Free Movies',
                    categoryId: 'free',
                    itemsStartId: 'free',
                    upId: 'home_banner_watch',
                  ),
                  const SizedBox(height: 30),
                  _buildMovieCategory(
                    title: 'Top Rated',
                    categoryId: 'top',
                    itemsStartId: 'top',
                    upId: 'free_movie_0',
                  ),
                  const SizedBox(height: 30),
                  _buildMovieCategory(
                    title: 'Featured',
                    categoryId: 'featured',
                    itemsStartId: 'featured',
                    upId: 'top_movie_0',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    final banner = {
      'title': 'Featured Movie',
      'description': 'Watch this amazing movie now!',
    };

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Banner content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  banner['title']!,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  banner['description']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    DebugFocusable(
                      id: 'home_banner_watch',
                      rightId: 'home_banner_like',
                      downId: 'free_movie_0',
                      showDebugInfo: DebugSettings.showDebugOverlay,
                      focusBuilder: (context, isFocused, isSelected, child) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(isFocused ? 2 : 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isFocused ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: child,
                        );
                      },
                      onSelect: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Playing ${banner['title']}')));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.play_arrow, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Watch Now',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DebugFocusable(
                      id: 'home_banner_like',
                      leftId: 'home_banner_watch',
                      downId: 'free_movie_1',
                      showDebugInfo: DebugSettings.showDebugOverlay,
                      focusBuilder: (context, isFocused, isSelected, child) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(isFocused ? 2 : 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isFocused ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: child,
                        );
                      },
                      onSelect: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Added ${banner['title']} to favorites')));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.favorite_border, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Add to Favorites',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCategory({
    required String title,
    required String categoryId,
    required String itemsStartId,
    String? upId,
  }) {
    // Generate different numbers of movies for each category
    int movieCount;
    switch (categoryId) {
      case 'free':
        movieCount = 8;
        break;
      case 'top':
        movieCount = 6; // Fewer movies in this category
        break;
      case 'featured':
        movieCount = 10; // More movies in this category
        break;
      default:
        movieCount = 8;
    }

    // Generate mock movie data
    final List<Map<String, dynamic>> movies = List.generate(
      movieCount,
      (index) => {
        'id': '$categoryId-movie-$index',
        'title': 'Movie ${index + 1}',
        'rating': (3 + (index % 3)) / 2 + 3,
      },
    );

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
              final String movieId =
                  '${itemsStartId.split('_')[0]}_movie_$index';

              // Calculate navigation IDs
              String? leftId = index > 0
                  ? '${itemsStartId.split('_')[0]}_movie_${index - 1}'
                  : 'sidebar_home';
              String? rightId = index < movies.length - 1
                  ? '${itemsStartId.split('_')[0]}_movie_${index + 1}'
                  : null;

              // Connect to the currently visible item in the previous category
              String? currentUpId;
              if (categoryId == 'free') {
                // Connect to banner buttons
                currentUpId =
                    index == 0 ? 'home_banner_watch' : 'home_banner_like';
              } else if (categoryId == 'top') {
                // Handle case where top category has fewer items than free category
                if (index < 8) {
                  // free category has 8 items
                  currentUpId = 'free_movie_$index';
                } else {
                  // If this index exceeds free category count, connect to last item
                  currentUpId = 'free_movie_7'; // Last item in free category
                }
              } else if (categoryId == 'featured') {
                // Handle case where featured has more items than top category
                if (index < 6) {
                  // top category has 6 items
                  currentUpId = 'top_movie_$index';
                } else {
                  // If this index exceeds top category count, connect to last item
                  currentUpId = 'top_movie_5'; // Last item in top category
                }
              }

              // Connect all items to the movies in the next category
              String? downId;
              if (categoryId == 'free') {
                // Connect to the corresponding movie in top category
                if (index < 6) {
                  // top category has 6 items
                  downId = 'top_movie_$index';
                } else {
                  // If this index exceeds top category count, don't set downId
                  downId = null;
                }
              } else if (categoryId == 'top') {
                // Connect to the corresponding movie in featured category
                if (index < 10) {
                  // featured category has 10 items
                  downId = 'featured_movie_$index';
                } else {
                  // This shouldn't happen as featured has more items than top
                  downId = null;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: MovieCard(
                  id: movieId,
                  title: movie['title'],
                  rating: movie['rating'],
                  leftId: leftId,
                  rightId: rightId,
                  upId: currentUpId,
                  downId: downId,
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

import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

import '../navigation/navigator_service.dart';
import '../widgets/home_banner.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "TTTTV",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          TVFocusable(
            id: "home-search-button",
            leftId: "nav-home",
            rightId: "home-profile-button",
            downId: "home-watch-button",
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ),
          TVFocusable(
            id: "home-profile-button",
            leftId: "home-search-button",
            downId: "home-watch-button",
            child: IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeBanner(),
            const SizedBox(height: 16),

            // Movies Section
            _buildContentSection(
              title: "Movies",
              icon: Icons.movie,
              color: Colors.red,
              id: "movies-section",
              upId: "home-watch-button",
              downId: "series-section",
              leftId: "nav-home",
            ),

            const SizedBox(height: 16),

            // Series Section
            _buildContentSection(
              title: "Series",
              icon: Icons.live_tv,
              color: Colors.blue,
              id: "series-section",
              upId: "movies-section-0",
              downId: "cartoons-section",
              leftId: "nav-home",
            ),

            const SizedBox(height: 16),

            // Cartoons Section
            _buildContentSection(
              title: "Cartoons",
              icon: Icons.emoji_emotions,
              color: Colors.green,
              id: "cartoons-section",
              upId: "series-section-0",
              leftId: "nav-home",
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required String title,
    required IconData icon,
    required Color color,
    required String id,
    String? downId,
    String? upId,
    String? leftId,
    String? rightId,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TVFocusable(
            id: id,
            upId: upId,
            downId: "$id-0",
            leftId: leftId,
            rightId: rightId,
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text("See all",
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: 10,
            itemBuilder: (context, index) {
              return TVFocusable(
                id: "$id-$index",
                upId: id,
                downId: downId,
                leftId: index == 0 ? leftId : "$id-${index - 1}",
                rightId: index == 9 ? null : "$id-${index + 1}",
                onFocus: () {},
                onSelect: () {
                  final movieTitle = "$title ${index + 1}";
                  final rating = 3.5 + index % 2 * 0.7;

                  // Sample description for demonstration
                  const description =
                      "This is a sample movie description. It tells you about the plot, the actors, and other interesting details about the movie. The description would normally be longer and provide more information.";

                  // Sample genres
                  final List<String> genres = ["Action", "Adventure"];
                  if (index % 2 == 0) genres.add("Sci-Fi");
                  if (index % 3 == 0) genres.add("Drama");

                  NavigatorService.push(
                    MovieDetailsScreen(
                      title: movieTitle,
                      rating: rating,
                      description: description,
                      releaseYear: "${2020 + index % 4}",
                      duration: "${90 + index * 5} min",
                      genres: genres,
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      context.setFocus("$id-$index");
                    }
                  });
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: color.withOpacity(0.3),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(Icons.image,
                            size: 50, color: color.withOpacity(0.5)),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            "$title ${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // Rating overlay
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                (3.5 + index % 2 * 0.7).toStringAsFixed(1),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

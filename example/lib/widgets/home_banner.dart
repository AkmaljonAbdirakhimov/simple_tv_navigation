import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

import '../navigation/navigator_service.dart';
import '../screens/movie_details_screen.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner>
    with SingleTickerProviderStateMixin {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  late AnimationController _indicatorController;
  final int _bannerCount = 5;

  final List<Color> _bannerColors = [
    Colors.red.shade800,
    Colors.blue.shade800,
    Colors.green.shade800,
    Colors.purple.shade800,
    Colors.orange.shade800,
  ];

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        if (_indicatorController.status == AnimationStatus.completed) {
          _indicatorController.reset();
          _nextBanner();
        }
      });

    _indicatorController.forward();

    _bannerController.addListener(() {
      if (_bannerController.page?.round() != _currentBannerIndex) {
        setState(() {
          _currentBannerIndex = _bannerController.page!.round();
          _indicatorController.reset();
          _indicatorController.forward();
        });
      }
    });
  }

  void _nextBanner() {
    final nextIndex = (_currentBannerIndex + 1) % _bannerCount;
    _bannerController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return // Banner Section with Slider
        SizedBox(
      height: 220,
      child: Stack(
        children: [
          // Banner PageView
          PageView.builder(
            controller: _bannerController,
            itemCount: _bannerCount,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _bannerColors[index],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.movie,
                          size: 80, color: Colors.white.withOpacity(0.3)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Featured Title ${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Experience the latest trending content",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Watch Button
          Positioned(
            right: 24,
            bottom: 24,
            child: TVFocusable(
              id: "home-watch-button",
              leftId: "nav-home",
              upId: "home-search-button",
              downId: "movies-section",
              child: ElevatedButton.icon(
                onPressed: () {
                  // Use current banner index to create featured movie data
                  final title = "Featured Title ${_currentBannerIndex + 1}";
                  final rating = 4.5 + (_currentBannerIndex * 0.1);

                  // Featured movies have longer descriptions
                  final description =
                      "This is a featured movie that's trending right now. "
                      "It features an all-star cast and an exciting storyline that keeps viewers engaged. "
                      "Critics have praised its direction and cinematography. "
                      "This is the perfect movie for your evening entertainment.";

                  // Sample genres for featured movies
                  final List<String> genres = ["Featured", "Trending"];
                  if (_currentBannerIndex % 2 == 0) genres.add("Blockbuster");
                  if (_currentBannerIndex % 3 == 0) genres.add("Award Winner");

                  NavigatorService.push(
                    MovieDetailsScreen(
                      title: title,
                      rating: rating,
                      description: description,
                      releaseYear: "${2023 + _currentBannerIndex % 2}",
                      duration: "${110 + _currentBannerIndex * 10} min",
                      genres: genres,
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text("Watch"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ),

          // Indicator dots
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: List.generate(
                _bannerCount,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentBannerIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          // Linear progress indicator
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _indicatorController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _indicatorController.value,
                  backgroundColor: Colors.transparent,
                  color: Colors.white,
                  minHeight: 2,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

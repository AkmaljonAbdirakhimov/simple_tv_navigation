import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

class Sidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onIndexChanged;

  const Sidebar({
    super.key,
    this.currentIndex = 0,
    this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TVFocusable(
            id: "nav-home",
            downId: "nav-profile",
            rightId: "home-watch-button",
            onFocus: () {
              onIndexChanged?.call(0);
            },
            child: IconButton(
              onPressed: () {
                onIndexChanged?.call(0);
              },
              icon: Icon(
                Icons.home,
                color: Colors.white,
                size: 28,
                // Highlight the active tab
                shadows: currentIndex == 0
                    ? [
                        const Shadow(
                          color: Colors.red,
                          blurRadius: 15,
                        )
                      ]
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TVFocusable(
            id: "nav-profile",
            upId: "nav-home",
            downId: "nav-settings",
            rightId: "home-search-button",
            onFocus: () => onIndexChanged?.call(1),
            child: IconButton(
              onPressed: () {
                onIndexChanged?.call(1);
              },
              icon: Icon(
                Icons.person,
                color: Colors.white,
                size: 28,
                // Highlight the active tab
                shadows: currentIndex == 1
                    ? [
                        const Shadow(
                          color: Colors.red,
                          blurRadius: 15,
                        )
                      ]
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TVFocusable(
            id: "nav-settings",
            upId: "nav-profile",
            rightId: "home-search-button",
            onFocus: () => onIndexChanged?.call(2),
            child: IconButton(
              onPressed: () {
                onIndexChanged?.call(2);
              },
              icon: Icon(
                Icons.settings,
                color: Colors.white,
                size: 28,
                // Highlight the active tab
                shadows: currentIndex == 2
                    ? [
                        const Shadow(
                          color: Colors.red,
                          blurRadius: 15,
                        )
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

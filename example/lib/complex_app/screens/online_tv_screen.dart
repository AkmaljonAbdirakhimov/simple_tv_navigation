import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

class OnlineTvScreen extends StatefulWidget {
  const OnlineTvScreen({super.key});

  @override
  State<OnlineTvScreen> createState() => _OnlineTvScreenState();
}

class _OnlineTvScreenState extends State<OnlineTvScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _channelCategories = [
    {
      'title': 'Sports',
      'id': 'sports',
      'channels': [
        {'name': 'ESPN'},
        {'name': 'Fox Sports'},
        {'name': 'Sky Sports'},
        {'name': 'NBC Sports'},
        {'name': 'Eurosport'},
        {'name': 'TNT Sports'},
        {'name': 'BeIN Sports'},
        {'name': 'DAZN'},
      ],
    },
    {
      'title': 'News',
      'id': 'news',
      'channels': [
        {'name': 'CNN'},
        {'name': 'BBC News'},
        {'name': 'Al Jazeera'},
        {'name': 'France 24'},
        {'name': 'Sky News'},
        {'name': 'CNBC'},
        {'name': 'Bloomberg'},
        {'name': 'Euronews'},
      ],
    },
    {
      'title': 'Shows',
      'id': 'shows',
      'channels': [
        {'name': 'HBO'},
        {'name': 'Netflix'},
        {'name': 'AMC'},
        {'name': 'Showtime'},
        {'name': 'ABC'},
        {'name': 'NBC'},
        {'name': 'CBS'},
        {'name': 'FOX'},
      ],
    },
    {
      'title': 'Kids',
      'id': 'kids',
      'channels': [
        {'name': 'Disney Channel'},
        {'name': 'Nickelodeon'},
        {'name': 'Cartoon Network'},
        {'name': 'PBS Kids'},
        {'name': 'Baby TV'},
        {'name': 'Boomerang'},
        {'name': 'Nick Jr.'},
        {'name': 'Disney Junior'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _channelCategories.length, vsync: this);
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
          // Title
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Online TV',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Tabs
          SizedBox(
            height: 48,
            child: Row(
              children: List.generate(
                _channelCategories.length,
                (index) => _buildTab(index),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Content based on selected tab
          Expanded(
            child: _buildChannelGrid(_selectedTab),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index) {
    final isSelected = _selectedTab == index;
    final category = _channelCategories[index];

    String? leftId = index > 0 ? 'tv_tab_${index - 1}' : 'sidebar_tv';
    String? rightId =
        index < _channelCategories.length - 1 ? 'tv_tab_${index + 1}' : null;
    String? downId = '${category['id']}_channel_0';

    return TVFocusable(
      id: 'tv_tab_$index',
      leftId: leftId,
      rightId: rightId,
      downId: downId,
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
            category['title'],
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

  Widget _buildChannelGrid(int tabIndex) {
    final category = _channelCategories[tabIndex];
    final channels = category['channels'] as List;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final channel = channels[index];
        final String channelId = '${category['id']}_channel_$index';

        // Calculate navigation paths
        final int row = index ~/ 4;
        final int col = index % 4;

        String? upId = row == 0 ? 'tv_tab_$tabIndex' : null;
        String? downId = row < ((channels.length - 1) ~/ 4)
            ? '${category['id']}_channel_${index + 4}'
            : null;
        String? leftId =
            col > 0 ? '${category['id']}_channel_${index - 1}' : 'sidebar_tv';
        String? rightId = col < 3 && index < channels.length - 1
            ? '${category['id']}_channel_${index + 1}'
            : null;

        return _buildChannelItem(
          id: channelId,
          name: channel['name'],
          upId: upId,
          downId: downId,
          leftId: leftId,
          rightId: rightId,
        );
      },
    );
  }

  Widget _buildChannelItem({
    required String id,
    required String name,
    String? upId,
    String? downId,
    String? leftId,
    String? rightId,
  }) {
    return TVFocusable(
      id: id,
      upId: upId,
      downId: downId,
      leftId: leftId,
      rightId: rightId,
      onSelect: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Watching $name channel')),
        );
      },
      focusBuilder: (context, isFocused, isSelected, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isFocused
              ? (Matrix4.identity()..scale(1.05))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2431),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

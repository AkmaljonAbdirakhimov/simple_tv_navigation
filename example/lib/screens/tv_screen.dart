import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

class TVScreen extends StatefulWidget {
  const TVScreen({super.key});

  @override
  State<TVScreen> createState() => _TVScreenState();
}

class _TVScreenState extends State<TVScreen> {
  final List<Map<String, dynamic>> _channels = [];
  final List<Map<String, dynamic>> _programs = [];
  int _selectedChannelIndex = 0;
  DateTime _currentDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    // Generate channels
    final channelIcons = [
      Icons.live_tv,
      Icons.tv,
      Icons.hd,
      Icons.sports,
      Icons.music_note,
      Icons.movie,
      Icons.brightness_low,
      Icons.record_voice_over,
      Icons.menu_book,
      Icons.video_settings,
    ];

    final channelColors = [
      Colors.red.shade700,
      Colors.blue.shade700,
      Colors.purple.shade700,
      Colors.green.shade700,
      Colors.pink.shade700,
      Colors.amber.shade700,
      Colors.cyan.shade700,
      Colors.teal.shade700,
      Colors.indigo.shade700,
      Colors.orange.shade700,
    ];

    for (int i = 0; i < 10; i++) {
      _channels.add({
        'id': i,
        'name': 'Channel ${i + 1}',
        'icon': channelIcons[i],
        'color': channelColors[i],
        'number': (i + 1).toString(),
      });
    }

    // Generate programs for each channel
    final programTitles = [
      'Morning News',
      'Cooking Show',
      'Documentary',
      'Reality TV',
      'Talk Show',
      'Movie',
      'Series',
      'Sports',
      'Game Show',
      'Kids Show',
    ];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 6, 0);

    for (int channelId = 0; channelId < 10; channelId++) {
      DateTime programStart = startOfDay;

      for (int i = 0; i < 12; i++) {
        final durationMinutes = 30 + (i % 3) * 30; // 30, 60, or 90 minutes
        final programEnd = programStart.add(Duration(minutes: durationMinutes));

        _programs.add({
          'id': '${channelId}_$i',
          'channelId': channelId,
          'title': programTitles[i % programTitles.length],
          'description':
              'This is a description for ${programTitles[i % programTitles.length]}',
          'startTime': programStart,
          'endTime': programEnd,
          'duration': durationMinutes,
        });

        programStart = programEnd;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Channel list (left side)
        Container(
          width: 200,
          color: Colors.grey[900],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Channels',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _channels.length,
                  itemBuilder: (context, index) {
                    return TVFocusable(
                      id: 'channel_$index',
                      leftId: 'sidebar_tv',
                      rightId: 'program_${index}_0',
                      upId: index > 0 ? 'channel_${index - 1}' : null,
                      downId: index < _channels.length - 1
                          ? 'channel_${index + 1}'
                          : null,
                      onFocus: () {
                        setState(() {
                          _selectedChannelIndex = index;
                        });
                      },
                      onSelect: () => _viewChannel(index),
                      focusBuilder: (context, isFocused, isSelected, child) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          color: isFocused
                              ? Colors.blue
                              : _selectedChannelIndex == index
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.transparent,
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _channels[index]['color'],
                              ),
                              child: Icon(
                                _channels[index]['icon'],
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _channels[index]['name'],
                                style: const TextStyle(
                                  fontSize: 16,
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
          ),
        ),

        // Program guide (right side)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(),
              Expanded(
                child: _buildProgramGuide(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _currentDay = _currentDay.subtract(const Duration(days: 1));
              });
            },
          ),
          const SizedBox(width: 16),
          Text(
            _formatDate(_currentDay),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                _currentDay = _currentDay.add(const Duration(days: 1));
              });
            },
          ),
          const Spacer(),
          Text(
            'Now: ${_formatTime(DateTime.now())}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramGuide() {
    final channelPrograms = _getChannelPrograms(_selectedChannelIndex);

    return ListView.builder(
      itemCount: channelPrograms.length,
      itemBuilder: (context, index) {
        final program = channelPrograms[index];

        return TVFocusable(
          id: 'program_${_selectedChannelIndex}_$index',
          leftId: 'channel_${_selectedChannelIndex}',
          rightId: index < channelPrograms.length - 1
              ? 'program_${_selectedChannelIndex}_${index + 1}'
              : null,
          upId: _selectedChannelIndex > 0
              ? 'program_${_selectedChannelIndex - 1}_$index'
              : null,
          downId: _selectedChannelIndex < _channels.length - 1
              ? 'program_${_selectedChannelIndex + 1}_$index'
              : null,
          onSelect: () => _viewProgram(program),
          focusBuilder: (context, isFocused, isSelected, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isFocused
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: isFocused ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: child,
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
            color: Colors.grey[850],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${_formatTime(program['startTime'])} - ${_formatTime(program['endTime'])}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${program['duration']} min',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    program['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    program['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getChannelPrograms(int channelIndex) {
    return _programs
        .where((program) => program['channelId'] == channelIndex)
        .toList();
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday, $month ${date.day}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _viewChannel(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Watching ${_channels[index]['name']}')),
    );
  }

  void _viewProgram(Map<String, dynamic> program) {
    final channelName = _channels[program['channelId']]['name'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Watching ${program['title']} on $channelName')),
    );
  }
}

import 'package:flutter/material.dart';
import 'debug_focusable.dart';

class MovieCard extends StatelessWidget {
  final String id;
  final String title;
  final double rating;
  final String? leftId;
  final String? rightId;
  final String? upId;
  final String? downId;
  final VoidCallback? onSelect;
  final bool showDebugInfo;

  const MovieCard({
    super.key,
    required this.id,
    required this.title,
    required this.rating,
    this.leftId,
    this.rightId,
    this.upId,
    this.downId,
    this.onSelect,
    this.showDebugInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 220,
      child: DebugFocusable(
        id: id,
        leftId: leftId,
        rightId: rightId,
        upId: upId,
        downId: downId,
        showDebugInfo: showDebugInfo,
        onSelect: onSelect,
        focusBuilder: (context, isFocused, isSelected, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFocused ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: child,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.movie,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DebugOverlay extends StatelessWidget {
  final String id;
  final String? leftId;
  final String? rightId;
  final String? upId;
  final String? downId;

  const DebugOverlay({
    super.key,
    required this.id,
    this.leftId,
    this.rightId,
    this.upId,
    this.downId,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            width: 150, // Base width constraint
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ID: $id',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                _buildDirectionInfo('↑', upId),
                _buildDirectionInfo('↓', downId),
                _buildDirectionInfo('←', leftId),
                _buildDirectionInfo('→', rightId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionInfo(String arrow, String? targetId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          arrow,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
          ),
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            targetId ?? 'null',
            style: TextStyle(
              color: targetId != null ? Colors.green : Colors.red,
              fontSize: 8,
              overflow: TextOverflow.ellipsis,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/rendering.dart';
import '../bloc/tv_navigation_bloc.dart';
import '../models/focus_direction.dart';
import '../models/navigation_event.dart';

/// Utility class for analyzing and optimizing TV navigation patterns
class NavigationAnalyzer {
  /// Identifies problematic navigation paths where elements can't be reached
  static List<String> findUnreachableElements(TVNavigationState state) {
    final reachableIds = <String>{};
    final allIds = state.elements.keys.toSet();

    // Start from each element and see what can be reached from it
    for (final startId in allIds) {
      final element = state.elements[startId];
      if (element == null || !element.isRegistered) continue;

      // Add the starting element
      reachableIds.add(startId);

      // Add its direct neighbors
      if (element.leftId != null &&
          state.elements.containsKey(element.leftId)) {
        reachableIds.add(element.leftId!);
      }
      if (element.rightId != null &&
          state.elements.containsKey(element.rightId)) {
        reachableIds.add(element.rightId!);
      }
      if (element.upId != null && state.elements.containsKey(element.upId)) {
        reachableIds.add(element.upId!);
      }
      if (element.downId != null &&
          state.elements.containsKey(element.downId)) {
        reachableIds.add(element.downId!);
      }
    }

    // Find the unreachable elements
    final unreachableIds = allIds.difference(reachableIds).toList();

    // Filter to only include registered elements
    return unreachableIds
        .where((id) => state.elements[id]?.isRegistered ?? false)
        .toList();
  }

  /// Identifies navigation dead-ends where you can get in but not out
  static List<String> findDeadEnds(TVNavigationState state) {
    final deadEnds = <String>[];

    for (final element in state.elements.values) {
      if (!element.isRegistered) continue;

      bool hasExit = false;

      // Check if the element has any exits
      if (element.leftId != null &&
          state.elements.containsKey(element.leftId)) {
        hasExit = true;
      } else if (element.rightId != null &&
          state.elements.containsKey(element.rightId)) {
        hasExit = true;
      } else if (element.upId != null &&
          state.elements.containsKey(element.upId)) {
        hasExit = true;
      } else if (element.downId != null &&
          state.elements.containsKey(element.downId)) {
        hasExit = true;
      }

      // If no exits, it's a dead end
      if (!hasExit) {
        deadEnds.add(element.id);
      }
    }

    return deadEnds;
  }

  /// Suggests optimal navigation connections based on element positions
  static Map<String, Map<FocusDirection, String>> suggestOptimalConnections(
      TVNavigationState state) {
    final suggestions = <String, Map<FocusDirection, String>>{};

    for (final element in state.elements.values) {
      if (!element.isRegistered || element.renderBox == null) continue;

      final elementBox = element.renderBox!;
      final elementRect = elementBox.localToGlobal(
            elementBox.paintBounds.topLeft,
          ) &
          elementBox.size;

      final directionSuggestions = <FocusDirection, String>{};

      // Try to find the best element in each direction
      for (final direction in [
        FocusDirection.left,
        FocusDirection.right,
        FocusDirection.up,
        FocusDirection.down,
      ]) {
        String? bestElementId;
        double bestScore = double.infinity;

        for (final candidate in state.elements.values) {
          if (!candidate.isRegistered ||
              candidate.id == element.id ||
              candidate.renderBox == null) {
            continue;
          }

          final candidateBox = candidate.renderBox!;
          final candidateRect = candidateBox.localToGlobal(
                candidateBox.paintBounds.topLeft,
              ) &
              candidateBox.size;

          // Check if candidate is in the right direction
          bool isCorrectDirection = false;
          switch (direction) {
            case FocusDirection.left:
              isCorrectDirection = candidateRect.right <= elementRect.left;
              break;
            case FocusDirection.right:
              isCorrectDirection = candidateRect.left >= elementRect.right;
              break;
            case FocusDirection.up:
              isCorrectDirection = candidateRect.bottom <= elementRect.top;
              break;
            case FocusDirection.down:
              isCorrectDirection = candidateRect.top >= elementRect.bottom;
              break;
            default:
              continue;
          }

          if (!isCorrectDirection) continue;

          // Calculate distance and alignment score
          final score = _calculateNavigationScore(
            elementRect,
            candidateRect,
            direction,
          );

          if (score < bestScore) {
            bestScore = score;
            bestElementId = candidate.id;
          }
        }

        if (bestElementId != null) {
          directionSuggestions[direction] = bestElementId;
        }
      }

      if (directionSuggestions.isNotEmpty) {
        suggestions[element.id] = directionSuggestions;
      }
    }

    return suggestions;
  }

  /// Calculate a score for navigation between two elements in a given direction
  /// Lower score is better
  static double _calculateNavigationScore(
    Rect source,
    Rect target,
    FocusDirection direction,
  ) {
    final sourceCenter = source.center;
    final targetCenter = target.center;

    // Base distance
    double distance = (sourceCenter - targetCenter).distance;

    // Penalize misalignment based on direction
    double alignmentPenalty = 0;

    switch (direction) {
      case FocusDirection.left:
      case FocusDirection.right:
        // For horizontal navigation, penalize vertical offset
        alignmentPenalty = (sourceCenter.dy - targetCenter.dy).abs() * 2;
        break;
      case FocusDirection.up:
      case FocusDirection.down:
        // For vertical navigation, penalize horizontal offset
        alignmentPenalty = (sourceCenter.dx - targetCenter.dx).abs() * 2;
        break;
      default:
        break;
    }

    return distance + alignmentPenalty;
  }

  /// Analyzes navigation history to provide insights
  static Map<String, dynamic> analyzeNavigationHistory(
      List<NavigationEvent> history) {
    if (history.isEmpty) {
      return {
        'totalEvents': 0,
        'successRate': 0.0,
        'mostFrequentSource': null,
        'mostFrequentDirection': null,
      };
    }

    int totalEvents = history.length;
    int successfulEvents = history.where((e) => e.successful).length;
    double successRate = successfulEvents / totalEvents;

    // Count frequency of source elements
    final sourceFrequency = <String, int>{};
    for (final event in history) {
      sourceFrequency[event.sourceId] =
          (sourceFrequency[event.sourceId] ?? 0) + 1;
    }

    // Find most frequent source
    String? mostFrequentSource;
    int maxSourceFrequency = 0;
    for (final entry in sourceFrequency.entries) {
      if (entry.value > maxSourceFrequency) {
        maxSourceFrequency = entry.value;
        mostFrequentSource = entry.key;
      }
    }

    // Count frequency of directions
    final directionFrequency = <FocusDirection, int>{};
    for (final event in history) {
      directionFrequency[event.direction] =
          (directionFrequency[event.direction] ?? 0) + 1;
    }

    // Find most frequent direction
    FocusDirection? mostFrequentDirection;
    int maxDirectionFrequency = 0;
    for (final entry in directionFrequency.entries) {
      if (entry.value > maxDirectionFrequency) {
        maxDirectionFrequency = entry.value;
        mostFrequentDirection = entry.key;
      }
    }

    return {
      'totalEvents': totalEvents,
      'successRate': successRate,
      'mostFrequentSource': mostFrequentSource,
      'mostFrequentSourceCount': maxSourceFrequency,
      'mostFrequentDirection': mostFrequentDirection,
      'mostFrequentDirectionCount': maxDirectionFrequency,
    };
  }

  /// Generates a DOT graph representation of the navigation relationships
  static String generateNavigationGraph(TVNavigationState state) {
    final buffer = StringBuffer();

    buffer.writeln('digraph TVNavigation {');
    buffer.writeln('  rankdir=LR;');
    buffer.writeln('  node [shape=box, style=filled, color=lightblue];');

    // Define nodes
    for (final element in state.elements.values) {
      if (!element.isRegistered) continue;

      final nodeStyle = element.isFocused
          ? 'color=orange, style=filled'
          : element.isSelected
              ? 'color=green, style=filled'
              : 'color=lightblue, style=filled';

      buffer.writeln('  "${element.id}" [$nodeStyle];');
    }

    // Define edges
    for (final element in state.elements.values) {
      if (!element.isRegistered) continue;

      if (element.leftId != null &&
          state.elements.containsKey(element.leftId)) {
        buffer.writeln(
            '  "${element.id}" -> "${element.leftId}" [label="left", color=blue];');
      }

      if (element.rightId != null &&
          state.elements.containsKey(element.rightId)) {
        buffer.writeln(
            '  "${element.id}" -> "${element.rightId}" [label="right", color=green];');
      }

      if (element.upId != null && state.elements.containsKey(element.upId)) {
        buffer.writeln(
            '  "${element.id}" -> "${element.upId}" [label="up", color=red];');
      }

      if (element.downId != null &&
          state.elements.containsKey(element.downId)) {
        buffer.writeln(
            '  "${element.id}" -> "${element.downId}" [label="down", color=purple];');
      }
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}

import 'package:equatable/equatable.dart';
import 'focus_direction.dart';

/// Represents a navigation event in the TV navigation system
class NavigationEvent extends Equatable {
  /// The ID of the element that initiated the event
  final String sourceId;

  /// The ID of the target element (if applicable)
  final String? targetId;

  /// The direction of the navigation
  final FocusDirection direction;

  /// The timestamp when the event occurred
  final DateTime timestamp;

  /// Whether the navigation was successful
  final bool successful;

  /// Any additional metadata related to this event
  final Map<String, dynamic>? metadata;

  /// Constructor
  NavigationEvent({
    required this.sourceId,
    this.targetId,
    required this.direction,
    DateTime? timestamp,
    this.successful = true,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a success navigation event
  factory NavigationEvent.success({
    required String sourceId,
    required String targetId,
    required FocusDirection direction,
    Map<String, dynamic>? metadata,
  }) {
    return NavigationEvent(
      sourceId: sourceId,
      targetId: targetId,
      direction: direction,
      successful: true,
      metadata: metadata,
    );
  }

  /// Create a failed navigation event
  factory NavigationEvent.failure({
    required String sourceId,
    String? targetId,
    required FocusDirection direction,
    Map<String, dynamic>? metadata,
  }) {
    return NavigationEvent(
      sourceId: sourceId,
      targetId: targetId,
      direction: direction,
      successful: false,
      metadata: metadata,
    );
  }

  /// Create a copy of this event with modified properties
  NavigationEvent copyWith({
    String? sourceId,
    String? targetId,
    FocusDirection? direction,
    DateTime? timestamp,
    bool? successful,
    Map<String, dynamic>? metadata,
  }) {
    return NavigationEvent(
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
      successful: successful ?? this.successful,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props =>
      [sourceId, targetId, direction, timestamp, successful, metadata];

  @override
  String toString() => 'NavigationEvent('
      'sourceId: $sourceId, '
      'targetId: $targetId, '
      'direction: $direction, '
      'successful: $successful)';
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

const _holdDelay = Duration(milliseconds: 450);
const _holdInterval = Duration(milliseconds: 90);

/// Just short of [_holdDelay], so a hold has started but not yet repeated.
const _beforeThreshold = Duration(milliseconds: 449);

/// Mounts a provider over a vertical chain a -> b -> c -> d so arrow repeats
/// are observable as focus landing on each link in turn.
Future<TvNavigationBloc> _mountChain(
  WidgetTester tester, {
  bool enableHoldToRepeat = true,
}) async {
  late TvNavigationBloc bloc;
  await tester.pumpWidget(
    MaterialApp(
      home: TvNavigationProvider(
        enableHoldToRepeat: enableHoldToRepeat,
        holdToRepeatDelay: _holdDelay,
        holdToRepeatInterval: _holdInterval,
        longPressThreshold: _holdDelay,
        child: Builder(
          builder: (context) {
            bloc = context.tvBloc;
            return const Scaffold(
              body: Column(
                children: [
                  TVFocusable(
                    id: 'a',
                    autofocus: true,
                    downId: 'b',
                    child: SizedBox(height: 20),
                  ),
                  TVFocusable(
                    id: 'b',
                    downId: 'c',
                    child: SizedBox(height: 20),
                  ),
                  TVFocusable(
                    id: 'c',
                    downId: 'd',
                    child: SizedBox(height: 20),
                  ),
                  TVFocusable(id: 'd', child: SizedBox(height: 20)),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
  // Flush the post-frame element registration and the autofocus state update.
  await tester.pump();
  return bloc;
}

Future<TvNavigationBloc> _mountSelect(
  WidgetTester tester, {
  VoidCallback? onSelect,
  VoidCallback? onLongPress,
}) async {
  late TvNavigationBloc bloc;
  await tester.pumpWidget(
    MaterialApp(
      home: TvNavigationProvider(
        holdToRepeatDelay: _holdDelay,
        holdToRepeatInterval: _holdInterval,
        longPressThreshold: _holdDelay,
        child: Builder(
          builder: (context) {
            bloc = context.tvBloc;
            return Scaffold(
              body: TVFocusable(
                id: 'only',
                autofocus: true,
                onSelect: onSelect,
                onLongPress: onLongPress,
                child: const SizedBox(height: 20),
              ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pump();
  return bloc;
}

/// Detaches the provider so its keyboard handler leaves the global
/// [HardwareKeyboard] handler list before the next test runs.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}

String? _focusedId(TvNavigationBloc bloc) =>
    bloc.state.currentlyFocusedElement?.id;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('hold to repeat', () {
    testWidgets('arrow key moves once on press', (tester) async {
      final bloc = await _mountChain(tester);

      expect(await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown), isTrue);
      await tester.pump();

      expect(_focusedId(bloc), 'b');
      await _unmount(tester);
    });

    testWidgets('arrow key does not repeat before the delay elapses',
        (tester) async {
      final bloc = await _mountChain(tester);

      await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.pump(_beforeThreshold);

      expect(_focusedId(bloc), 'b');
      await _unmount(tester);
    });

    testWidgets('holding an arrow key walks the chain at the repeat interval',
        (tester) async {
      final bloc = await _mountChain(tester);

      await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_focusedId(bloc), 'b');

      // Crosses the 450ms hold delay: one repeat lands on 'c'.
      await tester.pump(_holdDelay);
      expect(_focusedId(bloc), 'c');

      // 90ms later the next repeat lands on 'd'.
      await tester.pump(_holdInterval);
      expect(_focusedId(bloc), 'd');

      await _unmount(tester);
    });

    testWidgets('releasing the arrow key stops the repeat', (tester) async {
      final bloc = await _mountChain(tester);

      await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.pump(_holdDelay);
      expect(_focusedId(bloc), 'c');

      await simulateKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 500));

      expect(_focusedId(bloc), 'c');
      await _unmount(tester);
    });

    testWidgets('platform repeats do not stack on top of the hold timer',
        (tester) async {
      final bloc = await _mountChain(tester);

      await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_focusedId(bloc), 'b');

      // A remote that reports its own repeats must not add extra moves.
      for (var i = 0; i < 3; i++) {
        await simulateKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(_focusedId(bloc), 'b');

      // The hold timer still moves exactly one step, not one per OS repeat.
      await tester.pump(_holdDelay);
      expect(_focusedId(bloc), 'c');

      await _unmount(tester);
    });

    testWidgets('enableHoldToRepeat false keeps the legacy one-press behavior',
        (tester) async {
      final bloc = await _mountChain(tester, enableHoldToRepeat: false);

      await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_focusedId(bloc), 'b');

      await tester.pump(const Duration(seconds: 2));
      expect(_focusedId(bloc), 'b');

      await _unmount(tester);
    });
  });

  group('select', () {
    testWidgets('without onLongPress the key stays a plain on-press',
        (tester) async {
      var selects = 0;
      await _mountSelect(tester, onSelect: () => selects++);

      await simulateKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selects, 1);

      // Held down: still exactly one selection, no repeat path at all.
      await tester.pump(const Duration(seconds: 2));
      expect(selects, 1);

      await simulateKeyUpEvent(LogicalKeyboardKey.enter);
      await _unmount(tester);
    });

    testWidgets('with onLongPress, a tap still fires onSelect exactly once',
        (tester) async {
      var selects = 0;
      var longPresses = 0;
      await _mountSelect(
        tester,
        onSelect: () => selects++,
        onLongPress: () => longPresses++,
      );

      await simulateKeyDownEvent(LogicalKeyboardKey.select);
      await tester.pump(_beforeThreshold);

      expect(selects, 1);
      expect(longPresses, 0);

      await _unmount(tester);
    });

    testWidgets('with onLongPress, holding repeats the long press',
        (tester) async {
      var selects = 0;
      var longPresses = 0;
      await _mountSelect(
        tester,
        onSelect: () => selects++,
        onLongPress: () => longPresses++,
      );

      await simulateKeyDownEvent(LogicalKeyboardKey.select);
      await tester.pump();
      expect(selects, 1);
      expect(longPresses, 0);

      // Crosses the 450ms threshold.
      await tester.pump(_holdDelay);
      expect(longPresses, 1);

      await tester.pump(_holdInterval);
      expect(longPresses, 2);

      await simulateKeyUpEvent(LogicalKeyboardKey.select);
      await tester.pump(const Duration(seconds: 1));
      expect(longPresses, 2);
      expect(selects, 1);

      await _unmount(tester);
    });
  });
}

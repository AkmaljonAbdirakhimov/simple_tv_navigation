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
  VoidCallback? onLongPressEnd,
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
                onLongPressEnd: onLongPressEnd,
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

/// Two holdable elements in a chain, so focus can drift while select is held.
/// Every callback reports which element it came from.
Future<TvNavigationBloc> _mountPair(
  WidgetTester tester, {
  void Function(String id)? onSelect,
  void Function(String id)? onLongPress,
  void Function(String id)? onLongPressEnd,
}) async {
  late TvNavigationBloc bloc;
  Widget item(String id, {bool autofocus = false}) => TVFocusable(
        id: id,
        autofocus: autofocus,
        downId: id == 'a' ? 'b' : null,
        onSelect: onSelect == null ? null : () => onSelect(id),
        onLongPress: onLongPress == null ? null : () => onLongPress(id),
        onLongPressEnd: onLongPressEnd == null ? null : () => onLongPressEnd(id),
        child: const SizedBox(height: 20),
      );
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
              body: Column(
                children: [item('a', autofocus: true), item('b')],
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

    testWidgets('a tap on a holdable element runs onSelect only',
        (tester) async {
      var selects = 0;
      var longPresses = 0;
      var longPressEnds = 0;
      await _mountSelect(
        tester,
        onSelect: () => selects++,
        onLongPress: () => longPresses++,
        onLongPressEnd: () => longPressEnds++,
      );

      await simulateKeyDownEvent(LogicalKeyboardKey.select);
      await tester.pump(_beforeThreshold);

      // The tap is deferred to the release so a hold cannot also fire it.
      expect(selects, 0);
      expect(longPresses, 0);
      expect(longPressEnds, 0);

      await simulateKeyUpEvent(LogicalKeyboardKey.select);
      await tester.pump();

      expect(selects, 1);
      expect(longPresses, 0);
      // No hold ever started, so there is no end to report.
      expect(longPressEnds, 0);

      await _unmount(tester);
    });

    testWidgets('holding runs onLongPress and never onSelect', (tester) async {
      var selects = 0;
      var longPresses = 0;
      var longPressEnds = 0;
      await _mountSelect(
        tester,
        onSelect: () => selects++,
        onLongPress: () => longPresses++,
        onLongPressEnd: () => longPressEnds++,
      );

      await simulateKeyDownEvent(LogicalKeyboardKey.select);
      await tester.pump();

      // Crosses the 450ms threshold.
      await tester.pump(_holdDelay);
      expect(longPresses, 1);

      await tester.pump(_holdInterval);
      expect(longPresses, 2);

      await simulateKeyUpEvent(LogicalKeyboardKey.select);
      await tester.pump(const Duration(seconds: 1));

      expect(longPresses, 2);
      // The whole point: one hold never also fires the tap.
      expect(selects, 0);
      expect(longPressEnds, 1);

      await _unmount(tester);
    });

    testWidgets('focus moving mid-hold cannot retarget the callbacks',
        (tester) async {
      final selects = <String>[];
      final longPresses = <String>[];
      final longPressEnds = <String>[];
      final bloc = await _mountPair(
        tester,
        onSelect: selects.add,
        onLongPress: longPresses.add,
        onLongPressEnd: longPressEnds.add,
      );
      expect(_focusedId(bloc), 'a');

      await simulateKeyDownEvent(LogicalKeyboardKey.select);
      // Moved straight through the bloc: going through the key handler would
      // cancel the select hold instead of racing it.
      bloc.add(const MoveFocus(TvFocusDirection.down));
      await tester.pump();
      expect(_focusedId(bloc), 'b');

      await tester.pump(_holdDelay);
      // The press belongs to the element it started on.
      expect(longPresses, ['a']);

      await simulateKeyUpEvent(LogicalKeyboardKey.select);
      await tester.pump(const Duration(seconds: 1));

      expect(longPressEnds, ['a']);
      // And the deferred tap must not land on whatever took the focus.
      expect(selects, isEmpty);

      await _unmount(tester);
    });

    testWidgets('a key the widget does not own cannot end a running hold',
        (tester) async {
      var selects = 0;
      var longPresses = 0;
      var longPressEnds = 0;
      await _mountSelect(
        tester,
        onSelect: () => selects++,
        onLongPress: () => longPresses++,
        onLongPressEnd: () => longPressEnds++,
      );

      await simulateKeyDownEvent(LogicalKeyboardKey.select);
      await tester.pump(_holdDelay);
      expect(longPresses, 1);

      // A media key while select is still down: release must not truncate it.
      await simulateKeyDownEvent(LogicalKeyboardKey.mediaPlayPause);
      await simulateKeyUpEvent(LogicalKeyboardKey.mediaPlayPause);
      await tester.pump();
      expect(longPressEnds, 0);

      await tester.pump(_holdInterval);
      expect(longPresses, 2);

      await simulateKeyUpEvent(LogicalKeyboardKey.select);
      await tester.pump();
      expect(longPressEnds, 1);
      expect(selects, 0);

      await _unmount(tester);
    });

    testWidgets('disabling navigation mid-hold still reports the end',
        (tester) async {
      var selects = 0;
      var longPresses = 0;
      var longPressEnds = 0;
      final bloc = await _mountSelect(
        tester,
        onSelect: () => selects++,
        onLongPress: () => longPresses++,
        onLongPressEnd: () => longPressEnds++,
      );

      await simulateKeyDownEvent(LogicalKeyboardKey.select);
      await tester.pump(_holdDelay);
      expect(longPresses, 1);

      // The hold keeps ticking into a disabled bloc: it has to stop, and the
      // element has to hear about it so it can undo the change.
      bloc.add(const SetEnabled(false));
      await tester.pump(_holdInterval);
      expect(longPresses, 1);
      expect(longPressEnds, 1);

      await simulateKeyUpEvent(LogicalKeyboardKey.select);
      await tester.pump();
      expect(longPressEnds, 1);
      expect(selects, 0);

      await _unmount(tester);
    });
  });
}

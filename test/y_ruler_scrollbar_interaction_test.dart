import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';

void main() {
  testWidgets('YRulerScrollbar onInteraction callback test', (WidgetTester tester) async {
    final List<YScrollbarInteractionState> states = [];
    final controller = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: YRulerScrollbar(
            controller: controller,
            onInteraction: (state, offset) {
              states.add(state);
            },
            style: const YRulerScrollbarStyle(
              hitTestWidth: 40.0,
            ),
            child: ListView.builder(
              controller: controller,
              itemCount: 100,
              itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
            ),
          ),
        ),
      ),
    );

    final gestureDetectorFinder = find.byKey(const Key('y_ruler_scrollbar_gesture_detector'));
    expect(gestureDetectorFinder, findsOneWidget);

    // 1. Test Tap (Down -> Up)
    await tester.tap(gestureDetectorFinder);
    await tester.pumpAndSettle();
    expect(states.contains(YScrollbarInteractionState.down), true);
    expect(states.contains(YScrollbarInteractionState.up), true);

    // 2. Test Drag (Down -> Move -> Up)
    states.clear();
    final Offset center = tester.getCenter(gestureDetectorFinder);
    final TestGesture gesture = await tester.startGesture(center);
    await tester.pump(); // This should trigger down via onTapDown
    
    await gesture.moveBy(const Offset(0, 50));
    await tester.pump(); // This should trigger move via onVerticalDragUpdate
    
    await gesture.up();
    await tester.pump(); // This should trigger up via onVerticalDragEnd or onTapUp
    
    expect(states.contains(YScrollbarInteractionState.down), true);
    expect(states.contains(YScrollbarInteractionState.move), true);
    expect(states.contains(YScrollbarInteractionState.up), true);
  });
}

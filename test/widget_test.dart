import 'package:flutter_test/flutter_test.dart';
import 'package:vectorcalc/app.dart';
import 'package:vectorcalc/state/calc_state.dart';

void main() {
  testWidgets('calculator renders and evaluates', (tester) async {
    final state = CalcState();
    await tester.pumpWidget(VectorCalcApp(state: state));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('VECTORCALC'), findsOneWidget);

    state.insert('2');
    state.insert('+');
    state.insert('3');
    await tester.pump();
    state.evaluate();
    await tester.pump();

    expect(state.displayText, '5');
    expect(state.history.length, 1);
  });

  testWidgets('tapping keypad keys builds and evaluates', (tester) async {
    final state = CalcState();
    await tester.pumpWidget(VectorCalcApp(state: state));
    // Let the boot screen finish and the switch animation settle.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(state.expression, '7+3');

    await tester.tap(find.text('CALC').first);
    await tester.pump();
    expect(state.displayText, '10');
    expect(state.history.length, 1);
  });
}

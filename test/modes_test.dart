import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vectorcalc/state/calc_state.dart';
import 'package:vectorcalc/theme/themes.dart';
import 'package:vectorcalc/ui/basen_page.dart';
import 'package:vectorcalc/ui/cmplx_page.dart';
import 'package:vectorcalc/ui/eqn_page.dart';
import 'package:vectorcalc/ui/matrix_page.dart';
import 'package:vectorcalc/ui/stat_page.dart';
import 'package:vectorcalc/ui/table_page.dart';
import 'package:vectorcalc/ui/vector_page.dart';
import 'package:vectorcalc/ui/widgets.dart';

Widget host(Widget child) {
  final palette = appThemes.first.night;
  return MaterialApp(
    theme: buildThemeData(palette).copyWith(
      extensions: [PaletteTheme(palette)],
    ),
    home: child,
  );
}

/// Pumps a mode screen on a tall surface so lazily-built list children
/// (result wells below the fold) exist for assertions.
Future<void> pumpPage(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(1200, 2200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(host(child));
}

void main() {
  testWidgets('BASE-N converts decimal to binary', (tester) async {
    await pumpPage(tester, const BaseNPage());
    await tester.enterText(find.byType(TextField).first, '255');
    await tester.pump();
    expect(find.text('11111111'), findsOneWidget);
  });

  testWidgets('EQN solves a quadratic', (tester) async {
    await pumpPage(tester, const EqnPage());
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1');
    await tester.enterText(fields.at(1), '-5');
    await tester.enterText(fields.at(2), '6');
    await tester.tap(find.text('SOLVE'));
    await tester.pump();
    expect(find.text('x = 2'), findsOneWidget);
    expect(find.text('x = 3'), findsOneWidget);
  });

  testWidgets('TABLE evaluates f(x) over a range', (tester) async {
    final state = CalcState();
    await pumpPage(tester, TablePage(state: state));
    await tester.tap(find.text('GENERATE'));
    await tester.pump();
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('STAT computes a mean', (tester) async {
    await pumpPage(tester, const StatPage());
    await tester.enterText(find.byType(TextField).first, '2\n4\n4\n5\n7');
    await tester.tap(find.text('CALCULATE'));
    await tester.pump();
    expect(find.text('RESULTS'), findsOneWidget);
    expect(find.text('4.4'), findsOneWidget);
  });

  testWidgets('MATRIX computes a determinant', (tester) async {
    await pumpPage(tester, const MatrixPage());
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1');
    await tester.enterText(fields.at(1), '2');
    await tester.enterText(fields.at(2), '3');
    await tester.enterText(fields.at(3), '4');
    await tester.tap(find.text('det A'));
    await tester.pump();
    expect(find.text('-2'), findsOneWidget);
  });

  testWidgets('VECTOR computes a magnitude', (tester) async {
    await pumpPage(tester, const VectorPage());
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '3');
    await tester.enterText(fields.at(1), '4');
    await tester.tap(find.text('|A|'));
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('CMPLX multiplies two complex numbers', (tester) async {
    await pumpPage(tester, const CmplxPage());
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1');
    await tester.enterText(fields.at(1), '2');
    await tester.enterText(fields.at(2), '3');
    await tester.enterText(fields.at(3), '-4');
    await tester.tap(find.text('z₁ × z₂'));
    await tester.pump();
    expect(find.text('11 + 2i'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';

import '../core/num.dart';
import '../state/calc_state.dart';
import 'widgets.dart';

class VariablesPage extends StatelessWidget {
  final CalcState state;
  final VoidCallback? onInsert;

  const VariablesPage({super.key, required this.state, this.onInsert});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final names = [...variableNames, 'M'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Row(
            children: [
              const SectionLabel('Variables'),
              const Spacer(),
              Text(
                'Tap a card to insert, or store the current result.',
                style: TextStyle(fontSize: 11, color: p.keySub),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final name in names)
                    _VariableCard(
                      state: state,
                      name: name,
                      value: state.variables[name] ?? Num.i(0),
                      onInsert: onInsert,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VariableCard extends StatelessWidget {
  final CalcState state;
  final String name;
  final Num value;
  final VoidCallback? onInsert;

  const _VariableCard({
    required this.state,
    required this.name,
    required this.value,
    this.onInsert,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: 168,
      child: PixelPanel(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  color: p.accent,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: p.onAccent,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => state.clearVariable(name),
                  child: Icon(Icons.backspace_outlined,
                      size: 14, color: p.keySub),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 26,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  state.formatNum(value),
                  style: TextStyle(
                    fontFamily: 'VT323',
                    fontSize: 24,
                    color: p.keyText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: PixelButton(
                    label: 'USE',
                    compact: true,
                    onTap: () {
                      state.insert(name);
                      onInsert?.call();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: PixelButton(
                    label: 'STORE',
                    compact: true,
                    filled: true,
                    onTap: () => state.storeCurrentTo(name),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

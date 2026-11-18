import 'package:flutter/material.dart';

import '../core/verify.dart';
import '../state/calc_state.dart';
import 'mode_scaffold.dart';
import 'widgets.dart';

/// VERIFY: check whether an equation or inequality is true.
class VerifyPage extends StatefulWidget {
  final CalcState state;

  const VerifyPage({super.key, required this.state});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final _input = TextEditingController(text: '3+4=7');
  VerifyOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    _input.addListener(_run);
    _run();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _run() {
    final text = _input.text.trim();
    setState(() {
      _outcome = text.isEmpty
          ? null
          : verifyRelation(text, widget.state.evalContext);
    });
  }

  void _insertOperator(String op) {
    final text = _input.text;
    final rel = findRelation(text);
    final next = rel == null
        ? '$text$op'
        : '${text.substring(0, rel.index)}$op'
            '${text.substring(rel.index + rel.length)}';
    _input.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final o = _outcome;
    final verdict = o == null
        ? '—'
        : o.ok
            ? (o.result! ? 'TRUE' : 'FALSE')
            : 'ERROR';
    final verdictColor = o?.ok == true
        ? (o!.result! ? p.accent : p.keyText)
        : p.wellDim;

    return ModeScaffold(
      title: 'Verify',
      code: 'EQUALITY · INEQUALITY',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const SectionLabel('Relation'),
          const SizedBox(height: 8),
          PixelField(
            controller: _input,
            label: 'Expression',
            hint: '3+4=7',
            fontSize: 22,
            onChanged: (_) => _run(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final op in verifyOperators)
                ModeButton(
                  op,
                  onTap: () => _insertOperator(op),
                ),
            ],
          ),
          const SizedBox(height: 18),
          ResultWell(
            label: 'VERDICT',
            value: verdict,
            accent: verdictColor,
          ),
          if (o != null && o.ok) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ResultWell(
                    label: 'LEFT',
                    value: fmtNum(o.left!.v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultWell(
                    label: 'RIGHT',
                    value: fmtNum(o.right!.v),
                  ),
                ),
              ],
            ),
          ],
          if (o != null && !o.ok) ...[
            const SizedBox(height: 8),
            Text(
              o.error ?? 'Invalid relation',
              style: TextStyle(fontSize: 11.5, color: p.accent),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Accepts =  ≠  <  ≤  >  ≥. Both sides are evaluated with the '
            'current angle unit and variables.',
            style: TextStyle(fontSize: 11, height: 1.45, color: p.keySub),
          ),
        ],
      ),
    );
  }
}

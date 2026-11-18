import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/functions.dart';
import '../core/num.dart';
import '../state/calc_state.dart';
import 'widgets.dart';

class ConstantsPage extends StatefulWidget {
  final CalcState state;
  final VoidCallback? onInsert;

  const ConstantsPage({super.key, required this.state, this.onInsert});

  @override
  State<ConstantsPage> createState() => _ConstantsPageState();
}

class _ConstantsPageState extends State<ConstantsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final q = _query.toLowerCase();
    final items = constantCatalog.where((c) {
      if (q.isEmpty) return true;
      return c.label.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.symbol.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Row(
            children: [
              const SectionLabel('Constants'),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: p.panel,
                    border: Border.all(color: p.border),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(fontSize: 12, color: p.keyText),
                    cursorColor: p.accent,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Search constants',
                      hintStyle: TextStyle(fontSize: 12, color: p.keySub),
                      icon: Icon(Icons.search, size: 15, color: p.keySub),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: p.border.withValues(alpha: 0.6)),
            itemBuilder: (context, i) {
              final c = items[i];
              final value = physicalConstants[c.name] ?? 0;
              final text = formatValue(
                Num.of(value),
                const FormatSettings(),
                preferExact: false,
              );
              return InkWell(
                onTap: () {
                  widget.state.insert(c.name);
                  widget.onInsert?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: p.border),
                          color: p.keyFn,
                        ),
                        child: Text(
                          c.symbol,
                          style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: 19,
                            color: p.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: p.keyText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.unit.isEmpty ? c.name : '${c.name}  ·  ${c.unit}',
                              style: TextStyle(fontSize: 10, color: p.keySub),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        text,
                        style: TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 17,
                          color: p.keyText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.north_west, size: 13, color: p.keySub),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

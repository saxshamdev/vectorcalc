import 'package:flutter/material.dart';

import '../state/calc_state.dart';
import 'widgets.dart';

class HistoryPage extends StatelessWidget {
  final CalcState state;
  final VoidCallback? onRecall;

  const HistoryPage({super.key, required this.state, this.onRecall});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final entries = state.history;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Row(
            children: [
              const SectionLabel('History'),
              const SizedBox(width: 10),
              Text(
                '${entries.length}',
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 18,
                  color: p.keySub,
                ),
              ),
              const Spacer(),
              if (entries.isNotEmpty)
                PixelButton(
                  label: 'Clear',
                  icon: Icons.delete_outline,
                  compact: true,
                  onTap: state.clearHistory,
                ),
            ],
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 30, color: p.keySub),
                      const SizedBox(height: 10),
                      Text(
                        'Nothing here yet',
                        style: TextStyle(fontSize: 13, color: p.keySub),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Press = on the calculator to store a result.',
                        style: TextStyle(fontSize: 11, color: p.keySub),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: p.border.withValues(alpha: 0.6)),
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    return InkWell(
                      onTap: () {
                        state.recallHistory(e);
                        onRecall?.call();
                      },
                      onLongPress: () => state.removeHistoryAt(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.expression,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'VT323',
                                      fontSize: 16,
                                      color: p.keySub,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  SuperscriptText(
                                    e.result,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'VT323',
                                      fontSize: 24,
                                      color: p.keyText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (e.alt != null) ...[
                              const SizedBox(width: 12),
                              Text(
                                e.alt!,
                                style: TextStyle(
                                  fontFamily: 'VT323',
                                  fontSize: 16,
                                  color: p.keySub,
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            Icon(Icons.north_west, size: 14, color: p.keySub),
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

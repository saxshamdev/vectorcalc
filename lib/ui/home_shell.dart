import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../state/calc_state.dart';
import '../theme/themes.dart';
import '../ui/animated_logo.dart';
import '../ui/calculator_screen.dart';
import '../ui/constants_page.dart';
import '../ui/history_page.dart';
import '../ui/settings_page.dart';
import '../ui/variables_page.dart';
import '../ui/widgets.dart';

enum AppPage { calculator, history, variables, constants, settings }

class HomeShell extends StatefulWidget {
  final CalcState state;
  const HomeShell({super.key, required this.state});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  AppPage _page = AppPage.calculator;

  void _go(AppPage p) => setState(() => _page = p);

  Widget _body() {
    switch (_page) {
      case AppPage.calculator:
        return CalculatorScreen(state: widget.state, onOpenHistory: () => _go(AppPage.history));
      case AppPage.history:
        return HistoryPage(
          state: widget.state,
          onRecall: () => _go(AppPage.calculator),
        );
      case AppPage.variables:
        return VariablesPage(
          state: widget.state,
          onInsert: () => _go(AppPage.calculator),
        );
      case AppPage.constants:
        return ConstantsPage(
          state: widget.state,
          onInsert: () => _go(AppPage.calculator),
        );
      case AppPage.settings:
        return SettingsPage(state: widget.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final wide = MediaQuery.sizeOf(context).width >= 820;
    return Scaffold(
      backgroundColor: p.chassis,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              state: widget.state,
              wide: wide,
              onSettings: () => _go(AppPage.settings),
            ),
            Container(height: 1, color: p.border),
            Expanded(
              child: wide
                  ? Row(
                      children: [
                        _Rail(page: _page, onSelect: _go),
                        Container(width: 1, color: p.border),
                        Expanded(child: _body()),
                      ],
                    )
                  : _body(),
            ),
            if (!wide) _BottomNav(page: _page, onSelect: _go),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final CalcState state;
  final bool wide;
  final VoidCallback onSettings;

  const _TopBar({
    required this.state,
    required this.wide,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final short = MediaQuery.sizeOf(context).height < 640;
    final logoHeight = short ? 26.0 : (wide ? 44.0 : 32.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, color: p.accent),
                    const SizedBox(width: 9),
                    Text(
                      'VECTORCALC',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: wide ? 12 : 10,
                        letterSpacing: wide ? 2 : 1.2,
                        color: p.keyText,
                      ),
                    ),
                    if (wide) ...[
                      const SizedBox(width: 12),
                      Text(
                        'ENGINEERING',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 7,
                          letterSpacing: 1.4,
                          color: p.keySub,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: short ? 4 : 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedLogo(height: logoHeight),
                    const SizedBox(width: 10),
                    const Flexible(child: _TypeLine()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _IconBtn(
            icon: state.brightness == BrightnessMode.night
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            tooltip: state.brightness == BrightnessMode.night
                ? 'Switch to bright'
                : 'Switch to night',
            onTap: state.toggleBrightness,
          ),
          const SizedBox(width: 6),
          _IconBtn(
            icon: Icons.tune,
            tooltip: 'Settings',
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

/// A one-line retro typewriter that cycles through short status phrases.
class _TypeLine extends StatefulWidget {
  const _TypeLine();

  @override
  State<_TypeLine> createState() => _TypeLineState();
}

class _TypeLineState extends State<_TypeLine> {
  static const List<String> _messages = [
    'PRECISION ENGINE',
    'OFFLINE // NO NETWORK',
    'NATURAL-V.P.A.M.',
    'SYSTEM READY.',
  ];

  Timer? _timer;
  int _message = 0;
  int _chars = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 62), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final text = _messages[_message];
    if (_chars <= text.length + 26) {
      setState(() => _chars++);
      return;
    }
    setState(() {
      _message = (_message + 1) % _messages.length;
      _chars = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = _messages[_message];
    final shown = text.substring(0, math.min(_chars, text.length));
    final cursor = (_chars % 8) < 5 ? '▏' : ' ';
    return Text(
      '$shown$cursor',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: TextStyle(
        fontFamily: 'VT323',
        fontSize: 14,
        height: 1.1,
        letterSpacing: 0.6,
        color: p.keySub,
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(border: Border.all(color: p.border)),
          child: Icon(icon, size: 17, color: p.keyText),
        ),
      ),
    );
  }
}

class _NavEntry {
  final AppPage page;
  final IconData icon;
  final String label;
  const _NavEntry(this.page, this.icon, this.label);
}

const _entries = [
  _NavEntry(AppPage.calculator, Icons.calculate_outlined, 'CALC'),
  _NavEntry(AppPage.history, Icons.history, 'HIST'),
  _NavEntry(AppPage.variables, Icons.functions, 'VARS'),
  _NavEntry(AppPage.constants, Icons.science_outlined, 'CONST'),
  _NavEntry(AppPage.settings, Icons.tune, 'SET'),
];

class _BottomNav extends StatelessWidget {
  final AppPage page;
  final ValueChanged<AppPage> onSelect;

  const _BottomNav({required this.page, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.panel,
        border: Border(top: BorderSide(color: p.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          for (final e in _entries)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(e.page),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      e.icon,
                      size: 18,
                      color: e.page == page ? p.accent : p.keySub,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.label,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 6.5,
                        letterSpacing: 0.6,
                        color: e.page == page ? p.accent : p.keySub,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  final AppPage page;
  final ValueChanged<AppPage> onSelect;

  const _Rail({required this.page, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 76,
      color: p.panel,
      child: Column(
        children: [
          const SizedBox(height: 12),
          for (final e in _entries)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(e.page),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: e.page == page
                        ? p.accent.withValues(alpha: 0.14)
                        : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        width: 2,
                        color: e.page == page ? p.accent : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        e.icon,
                        size: 18,
                        color: e.page == page ? p.accent : p.keySub,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        e.label,
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 6,
                          letterSpacing: 0.4,
                          color: e.page == page ? p.accent : p.keySub,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

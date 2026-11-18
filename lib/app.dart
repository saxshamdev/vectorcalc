import 'package:flutter/material.dart';

import 'state/calc_state.dart';
import 'ui/home_shell.dart';
import 'ui/intro_screen.dart';
import 'theme/themes.dart';
import 'ui/widgets.dart';

class VectorCalcApp extends StatefulWidget {
  final CalcState state;
  const VectorCalcApp({super.key, required this.state});

  @override
  State<VectorCalcApp> createState() => _VectorCalcAppState();
}

class _VectorCalcAppState extends State<VectorCalcApp> {
  bool _introDone = false;

  ThemeData? _theme;
  String? _themeKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final palette = widget.state.palette;
        final key = '${widget.state.themeId}/${widget.state.brightness.name}';
        if (_theme == null || _themeKey != key) {
          _theme = buildThemeData(palette).copyWith(
            extensions: [PaletteTheme(palette)],
          );
          _themeKey = key;
        }
        final theme = _theme!;
        return MaterialApp(
          title: 'VECTORCALC',
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _introDone
                ? HomeShell(
                    key: const ValueKey('shell'),
                    state: widget.state,
                  )
                : IntroScreen(
                    key: const ValueKey('intro'),
                    onDone: () => setState(() => _introDone = true),
                  ),
          ),
        );
      },
    );
  }
}

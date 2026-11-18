import 'package:flutter/material.dart';

enum BrightnessMode { bright, night }

extension BrightnessModeLabel on BrightnessMode {
  String get label => this == BrightnessMode.night ? 'NIGHT' : 'BRIGHT';
}

/// A complete colour set for one theme in one brightness mode.
class Palette {
  final Color chassis;
  final Color panel;
  final Color well;
  final Color wellText;
  final Color wellDim;
  final Color keyNum;
  final Color keyFn;
  final Color keyOp;
  final Color keyText;
  final Color keySub;
  final Color accent;
  final Color onAccent;
  final Color border;
  final Color shadow;
  final bool isDark;

  const Palette({
    required this.chassis,
    required this.panel,
    required this.well,
    required this.wellText,
    required this.wellDim,
    required this.keyNum,
    required this.keyFn,
    required this.keyOp,
    required this.keyText,
    required this.keySub,
    required this.accent,
    required this.onAccent,
    required this.border,
    required this.shadow,
    required this.isDark,
  });

  /// Casio-style SHIFT legend: yellow/gold, readable on every key face.
  Color get shiftLegend => isDark
      ? const Color(0xFFE7B84B)
      : const Color(0xFF8A6000);

  /// Casio-style ALPHA legend: red, kept distinct from the theme accent.
  Color get alphaLegend => isDark
      ? const Color(0xFFE07A72)
      : const Color(0xFFA63A32);
}

class AppTheme {
  final String id;
  final String name;
  final String blurb;
  final Palette bright;
  final Palette night;

  const AppTheme({
    required this.id,
    required this.name,
    required this.blurb,
    required this.bright,
    required this.night,
  });

  Palette palette(BrightnessMode mode) =>
      mode == BrightnessMode.night ? night : bright;
}

const List<AppTheme> appThemes = [
  AppTheme(
    id: 'amber',
    name: 'Amber',
    blurb: 'Warm phosphor terminal',
    night: Palette(
      chassis: Color(0xFF121317),
      panel: Color(0xFF17181D),
      well: Color(0xFF0B0C0F),
      wellText: Color(0xFFFFB020),
      wellDim: Color(0xFFA87418),
      keyNum: Color(0xFF2E3138),
      keyFn: Color(0xFF26282E),
      keyOp: Color(0xFF34373F),
      keyText: Color(0xFFEDEAE3),
      keySub: Color(0xFF8C8A84),
      accent: Color(0xFFFFB020),
      onAccent: Color(0xFF121317),
      border: Color(0xFF34373F),
      shadow: Color(0xFF000000),
      isDark: true,
    ),
    bright: Palette(
      chassis: Color(0xFFE8E2D4),
      panel: Color(0xFFF2EDE1),
      well: Color(0xFFF7F2E6),
      wellText: Color(0xFF8A4B00),
      wellDim: Color(0xFFA97A34),
      keyNum: Color(0xFFFFFFFF),
      keyFn: Color(0xFFFBF7EC),
      keyOp: Color(0xFFF0E9D9),
      keyText: Color(0xFF22201C),
      keySub: Color(0xFF7C776C),
      accent: Color(0xFFB45309),
      onAccent: Color(0xFFFFF8EC),
      border: Color(0xFFC4BBA8),
      shadow: Color(0xFFB9AF9A),
      isDark: false,
    ),
  ),
  AppTheme(
    id: 'phosphor',
    name: 'Phosphor',
    blurb: 'Classic green CRT',
    night: Palette(
      chassis: Color(0xFF0F1411),
      panel: Color(0xFF141A16),
      well: Color(0xFF080C09),
      wellText: Color(0xFF7CFC9B),
      wellDim: Color(0xFF4C9E63),
      keyNum: Color(0xFF26302A),
      keyFn: Color(0xFF1E2620),
      keyOp: Color(0xFF2C3830),
      keyText: Color(0xFFE3EDE6),
      keySub: Color(0xFF7F8F85),
      accent: Color(0xFF7CFC9B),
      onAccent: Color(0xFF08110B),
      border: Color(0xFF2C3830),
      shadow: Color(0xFF000000),
      isDark: true,
    ),
    bright: Palette(
      chassis: Color(0xFFDDE5DC),
      panel: Color(0xFFE9EFE8),
      well: Color(0xFFF4F8F2),
      wellText: Color(0xFF1F6B3A),
      wellDim: Color(0xFF4B8C63),
      keyNum: Color(0xFFFFFFFF),
      keyFn: Color(0xFFF7FAF6),
      keyOp: Color(0xFFE4EBE3),
      keyText: Color(0xFF1C241E),
      keySub: Color(0xFF6E7A71),
      accent: Color(0xFF1F7A43),
      onAccent: Color(0xFFF4FBF6),
      border: Color(0xFFBCC9BD),
      shadow: Color(0xFFAEBBAF),
      isDark: false,
    ),
  ),
  AppTheme(
    id: 'beige',
    name: 'Beige',
    blurb: '80s lab hardware',
    night: Palette(
      chassis: Color(0xFF2A2622),
      panel: Color(0xFF332E29),
      well: Color(0xFF1E2B22),
      wellText: Color(0xFFC9F2C0),
      wellDim: Color(0xFF7FA478),
      keyNum: Color(0xFF4C443C),
      keyFn: Color(0xFF423B34),
      keyOp: Color(0xFF574E45),
      keyText: Color(0xFFF0E9DF),
      keySub: Color(0xFF9C9184),
      accent: Color(0xFFD9772E),
      onAccent: Color(0xFF241A12),
      border: Color(0xFF574E45),
      shadow: Color(0xFF000000),
      isDark: true,
    ),
    bright: Palette(
      chassis: Color(0xFFD8D2C4),
      panel: Color(0xFFE2DCCE),
      well: Color(0xFF39423A),
      wellText: Color(0xFFC9F2C0),
      wellDim: Color(0xFF8FB388),
      keyNum: Color(0xFFF7F2E7),
      keyFn: Color(0xFFEFE9DB),
      keyOp: Color(0xFFE3DCCB),
      keyText: Color(0xFF2B2822),
      keySub: Color(0xFF7A7365),
      accent: Color(0xFFB4551F),
      onAccent: Color(0xFFFFF6EA),
      border: Color(0xFFBDB5A4),
      shadow: Color(0xFFB0A896),
      isDark: false,
    ),
  ),
  AppTheme(
    id: 'paper',
    name: 'Paper',
    blurb: 'Ink on warm stock',
    night: Palette(
      chassis: Color(0xFF171614),
      panel: Color(0xFF1E1D1A),
      well: Color(0xFF0F0F0D),
      wellText: Color(0xFFF2E9D8),
      wellDim: Color(0xFFB9AC94),
      keyNum: Color(0xFF2C2A25),
      keyFn: Color(0xFF262420),
      keyOp: Color(0xFF35322C),
      keyText: Color(0xFFF2E9D8),
      keySub: Color(0xFF918877),
      accent: Color(0xFFE0A45C),
      onAccent: Color(0xFF1A1409),
      border: Color(0xFF3A3730),
      shadow: Color(0xFF000000),
      isDark: true,
    ),
    bright: Palette(
      chassis: Color(0xFFF4F1EA),
      panel: Color(0xFFFAF7F0),
      well: Color(0xFFFFFFFF),
      wellText: Color(0xFF1E1E1C),
      wellDim: Color(0xFF6B675E),
      keyNum: Color(0xFFFFFFFF),
      keyFn: Color(0xFFF7F4EC),
      keyOp: Color(0xFFEDE8DC),
      keyText: Color(0xFF1E1E1C),
      keySub: Color(0xFF7A7568),
      accent: Color(0xFFB45309),
      onAccent: Color(0xFFFFF8EC),
      border: Color(0xFFD9D3C6),
      shadow: Color(0xFFCFC8B9),
      isDark: false,
    ),
  ),
  AppTheme(
    id: 'graphite',
    name: 'Graphite',
    blurb: 'Monochrome instrument',
    night: Palette(
      chassis: Color(0xFF1A1A1C),
      panel: Color(0xFF202023),
      well: Color(0xFF0F0F10),
      wellText: Color(0xFFE8E6E1),
      wellDim: Color(0xFF8A8781),
      keyNum: Color(0xFF303035),
      keyFn: Color(0xFF2A2A2E),
      keyOp: Color(0xFF3A3A40),
      keyText: Color(0xFFE8E6E1),
      keySub: Color(0xFF85827C),
      accent: Color(0xFFC0504D),
      onAccent: Color(0xFFFDF6F5),
      border: Color(0xFF3A3A3F),
      shadow: Color(0xFF000000),
      isDark: true,
    ),
    bright: Palette(
      chassis: Color(0xFFE9E9E7),
      panel: Color(0xFFF2F2F0),
      well: Color(0xFFFFFFFF),
      wellText: Color(0xFF1B1B1D),
      wellDim: Color(0xFF6E6E72),
      keyNum: Color(0xFFFFFFFF),
      keyFn: Color(0xFFF4F4F2),
      keyOp: Color(0xFFE8E8E6),
      keyText: Color(0xFF1B1B1D),
      keySub: Color(0xFF74747A),
      accent: Color(0xFF9E3B38),
      onAccent: Color(0xFFFFF7F6),
      border: Color(0xFFD2D2CF),
      shadow: Color(0xFFC6C6C3),
      isDark: false,
    ),
  ),
];

AppTheme themeById(String id) =>
    appThemes.firstWhere((t) => t.id == id, orElse: () => appThemes.first);

ThemeData buildThemeData(Palette p) {
  final brightness = p.isDark ? Brightness.dark : Brightness.light;
  final base = p.isDark ? ThemeData.dark() : ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: p.chassis,
    canvasColor: p.chassis,
    dividerColor: p.border,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.accent,
      onSecondary: p.onAccent,
      error: const Color(0xFFC0504D),
      onError: Colors.white,
      surface: p.panel,
      onSurface: p.keyText,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: p.keyText,
      displayColor: p.keyText,
    ),
    iconTheme: IconThemeData(color: p.keyText),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.panel,
        border: Border.all(color: p.border),
      ),
      textStyle: TextStyle(
        color: p.keyText,
        fontSize: 12,
        fontFamily: 'monospace',
      ),
    ),
  );
}

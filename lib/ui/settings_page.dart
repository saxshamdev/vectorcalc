import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/functions.dart';
import '../state/calc_state.dart';
import '../theme/themes.dart';
import 'widgets.dart';

class SettingsPage extends StatelessWidget {
  final CalcState state;
  const SettingsPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final f = state.format;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        const SectionLabel('Appearance'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final t in appThemes)
              _ThemeCard(
                theme: t,
                selected: t.id == state.themeId,
                brightness: state.brightness,
                onTap: () => state.setTheme(t.id),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionLabel('Brightness'),
        const SizedBox(height: 8),
        PixelSegmented<BrightnessMode>(
          value: state.brightness,
          onChanged: state.setBrightness,
          options: const [
            SegmentedOption(BrightnessMode.bright, 'BRIGHT'),
            SegmentedOption(BrightnessMode.night, 'NIGHT'),
          ],
        ),
        _divider(p),
        const SectionLabel('Angle unit'),
        const SizedBox(height: 8),
        PixelSegmented<AngleMode>(
          value: state.angle,
          onChanged: state.setAngle,
          options: const [
            SegmentedOption(AngleMode.deg, 'DEG'),
            SegmentedOption(AngleMode.rad, 'RAD'),
            SegmentedOption(AngleMode.grad, 'GRAD'),
          ],
        ),
        _divider(p),
        const SectionLabel('Display format'),
        const SizedBox(height: 8),
        PixelSegmented<DisplayMode>(
          value: f.mode,
          onChanged: (m) => state.setFormat(f.copyWith(mode: m)),
          options: const [
            SegmentedOption(DisplayMode.norm, 'NORM'),
            SegmentedOption(DisplayMode.fix, 'FIX'),
            SegmentedOption(DisplayMode.sci, 'SCI'),
          ],
        ),
        if (f.mode != DisplayMode.norm) ...[
          const SizedBox(height: 10),
          SettingRow(
            title: f.mode == DisplayMode.fix ? 'Decimal places' : 'Digits',
            subtitle: '0 – 9',
            trailing: _Stepper(
              value: f.digits,
              onChanged: (v) => state.setFormat(f.copyWith(digits: v)),
            ),
          ),
        ],
        const SizedBox(height: 4),
        SettingRow(
          title: 'Engineering notation',
          subtitle: 'Powers of ten in steps of three',
          trailing: PixelSwitch(
            value: f.engineering,
            onChanged: (v) => state.setFormat(f.copyWith(engineering: v)),
          ),
        ),
        SettingRow(
          title: 'SI prefixes',
          subtitle: 'Show k, M, µ, n instead of ×10ⁿ',
          trailing: PixelSwitch(
            value: f.siPrefix,
            onChanged: (v) => state.setFormat(f.copyWith(siPrefix: v)),
          ),
        ),
        _divider(p),
        const SectionLabel('Result'),
        const SizedBox(height: 4),
        SettingRow(
          title: 'Exact results',
          subtitle: 'Show fractions and integers when possible (S⇔D)',
          trailing: PixelSwitch(
            value: state.exactPreferred,
            onChanged: (_) => state.toggleExact(),
          ),
        ),
        SettingRow(
          title: 'Mixed fractions',
          subtitle: 'Display 7/3 as 2 1/3',
          trailing: PixelSwitch(
            value: f.mixedFraction,
            onChanged: (v) => state.setFormat(f.copyWith(mixedFraction: v)),
          ),
        ),
        _divider(p),
        const SectionLabel('About'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.panel,
            border: Border.all(color: p.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VECTORCALC',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: p.keyText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 11, color: p.keySub),
              ),
              const SizedBox(height: 4),
              Text(
                'Offline engineering calculator. No accounts, no tracking, no network calls.',
                style: TextStyle(fontSize: 11, height: 1.5, color: p.keySub),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(Palette p) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Divider(height: 1, color: p.border),
      );
}

class _ThemeCard extends StatelessWidget {
  final AppTheme theme;
  final bool selected;
  final BrightnessMode brightness;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = theme.palette(brightness);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: p.panel,
          border: Border.all(
            color: selected ? p.accent : p.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 14, height: 14, color: t.accent),
                const SizedBox(width: 6),
                Container(width: 14, height: 14, color: t.keyNum),
                const SizedBox(width: 6),
                Container(width: 14, height: 14, color: t.well),
                const Spacer(),
                if (selected) Icon(Icons.check, size: 14, color: p.accent),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              theme.name,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: p.keyText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              theme.blurb,
              style: TextStyle(fontSize: 10, color: p.keySub),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _Stepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged((value - 1).clamp(0, 9)),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: p.border)),
            child: Text('−',
                style: TextStyle(
                    fontFamily: 'VT323', fontSize: 20, color: p.keyText)),
          ),
        ),
        SizedBox(
          width: 34,
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 20,
                color: p.keyText,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged((value + 1).clamp(0, 9)),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: p.border)),
            child: Text('+',
                style: TextStyle(
                    fontFamily: 'VT323', fontSize: 20, color: p.keyText)),
          ),
        ),
      ],
    );
  }
}

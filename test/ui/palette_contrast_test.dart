import 'dart:math' as math;

import 'package:b4due/ui/tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Every text/background pair the UI kit draws, by role.
Map<String, (Color, Color)> _pairs(Palette p) => {
  'text on background': (p.textPrimary, p.background),
  'text on surface': (p.textPrimary, p.surface),
  'secondary text on background': (p.textSecondary, p.background),
  'secondary text on surface': (p.textSecondary, p.surface),
  'secondary text on input': (p.textSecondary, p.surfaceVariant),
  'text on input': (p.textPrimary, p.surfaceVariant),
  'label on the main button': (p.onPrimary, p.primary),
  'emphasised text on background': (p.primaryText, p.background),
  'emphasised text on surface': (p.primaryText, p.surface),
  'emphasised text on soft fill': (p.primaryText, p.primarySoft),
  'label on the accent': (p.onAccent, p.accent),
  'accent text on background': (p.accentText, p.background),
  'accent text on surface': (p.accentText, p.surface),
  'accent text on accent tint': (p.accentText, p.accentSoft),
  'chart tooltip': (p.onInverseSurface, p.inverseSurface),
  'destructive button label': (p.onDanger, p.dangerText),
  'danger text on surface': (p.dangerText, p.surface),
  'paid chip': (p.successText, p.successSoft),
  'due-soon chip': (p.warningText, p.warningSoft),
  'today chip': (p.todayText, p.todaySoft),
  'overdue chip': (p.dangerText, p.dangerSoft),
  'upcoming chip': (p.neutralText, p.neutralSoft),
};

void main() {
  for (final (name, palette) in [
    ('light', Palette.light),
    ('dark', Palette.dark),
  ]) {
    group('$name palette meets WCAG AA (4.5:1)', () {
      for (final MapEntry(key: role, value: (fg, bg)) in _pairs(
        palette,
      ).entries) {
        test(role, () {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
        });
      }
    });
  }

  test('white text on every wallet card is AA', () {
    const white = Color(0xFFFFFFFF);
    for (final card in Palette.walletCards) {
      expect(contrast(white, card.start), greaterThanOrEqualTo(4.5));
      expect(contrast(white, card.end), greaterThanOrEqualTo(4.5));
    }
  });

  test('swipe backgrounds keep white text AA', () {
    const white = Color(0xFFFFFFFF);
    expect(contrast(white, const Color(0xFF067647)), greaterThanOrEqualTo(4.5));
    expect(contrast(white, const Color(0xFFB42318)), greaterThanOrEqualTo(4.5));
  });
}

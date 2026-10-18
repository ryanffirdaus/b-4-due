import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/theme_preference.dart';
import '../theme_controller.dart';

/// Terang / Gelap / Ikuti sistem, each with a small preview of the app.
class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(themePreferenceProvider);
    final options = [
      (ThemePreference.light, l10n.themeLight),
      (ThemePreference.dark, l10n.themeDark),
      (ThemePreference.system, l10n.themeSystem),
    ];
    return B4Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsTheme,
            style: context.text.bodyLarge.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(l10n.settingsThemeHelp, style: context.text.bodySmall),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _ThemeOption(
                    preference: options[i].$1,
                    label: options[i].$2,
                    selected: current == options[i].$1,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(themePreferenceProvider.notifier)
                          .set(options[i].$1);
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Tokens.sectionGap),
          Text(
            l10n.settingsAccent,
            style: context.text.bodyLarge.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(l10n.settingsAccentHelp, style: context.text.bodySmall),
          const SizedBox(height: 14),
          const _AccentRow(),
        ],
      ),
    );
  }
}

/// One swatch per accent; the chosen one gets a ring and a check.
class _AccentRow extends ConsumerWidget {
  const _AccentRow();

  static String _label(AppLocalizations l10n, AccentColors accent) =>
      switch (accent.name) {
        'sky' => l10n.accentSky,
        'coral' => l10n.accentCoral,
        'violet' => l10n.accentViolet,
        'amber' => l10n.accentAmber,
        'mint' => l10n.accentMint,
        _ => l10n.accentLime,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final current = ref.watch(accentProvider);
    return Wrap(
      spacing: 6,
      runSpacing: 10,
      children: [
        for (final accent in AccentColors.all)
          Pressable(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(accentProvider.notifier).set(accent);
            },
            selected: accent == current,
            semanticLabel: _label(l10n, accent),
            excludeChildSemantics: true,
            borderRadius: BorderRadius.circular(16),
            pressedScale: 0.92,
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: Tokens.motion,
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent == current
                            ? p.textPrimary
                            : const Color(0x00000000),
                        width: 2.5,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (p.isDark ? accent.dark : accent.light).fill,
                      ),
                      child: accent == current
                          ? Icon(
                              RemixIcons.checkLine,
                              size: 20,
                              color: (p.isDark ? accent.dark : accent.light)
                                  .onFill,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _label(l10n, accent),
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.preference,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ThemePreference preference;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(Tokens.controlRadius);
    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: label,
      excludeChildSemantics: true,
      borderRadius: radius,
      child: Column(
        children: [
          AnimatedContainer(
            duration: Tokens.motion,
            height: 88,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? p.primary : p.outline,
                width: selected ? 3 : 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Tokens.controlRadius - 4),
              child: switch (preference) {
                ThemePreference.light => const _Preview(Palette.light),
                ThemePreference.dark => const _Preview(Palette.dark),
                ThemePreference.system => const Row(
                  children: [
                    Expanded(child: _Preview(Palette.light)),
                    Expanded(child: _Preview(Palette.dark)),
                  ],
                ),
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.text.labelMedium.copyWith(
              color: selected ? p.primaryText : p.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A miniature screen in [palette]: page, two cards and an accent dot.
class _Preview extends StatelessWidget {
  const _Preview(this.palette);

  final Palette palette;

  @override
  Widget build(BuildContext context) {
    Widget bar(double widthFactor, Color color) => FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
    return Container(
      color: palette.background,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(0.9, palette.surface),
          const SizedBox(height: 6),
          bar(0.7, palette.surface),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: palette.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../domain/bill_category.dart';
import '../bill_labels.dart';

/// "Warna kartu": Otomatis (the category's colour) plus every wallet-card
/// colour, each as a small card swatch.
class CardColorPicker extends StatelessWidget {
  const CardColorPicker({
    required this.value,
    required this.category,
    required this.onChanged,
    super.key,
  });

  /// The chosen colour, or null for Otomatis.
  final int? value;
  final BillCategory category;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final names = cardColorNames(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              l10n.formCardColor,
              style: context.text.labelMedium.copyWith(color: p.textSecondary),
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Swatch(
              colors: walletCardColors(null, category),
              selected: value == null,
              label: '${l10n.formCardColorAuto}, ${l10n.formCardColorAutoHelp}',
              text: 'A',
              onTap: () => onChanged(null),
            ),
            for (var i = 0; i < Palette.walletCards.length; i++)
              _Swatch(
                colors: Palette.walletCards[i],
                selected: value == i,
                label: names[i],
                onTap: () => onChanged(i),
              ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.colors,
    required this.selected,
    required this.label,
    required this.onTap,
    this.text,
  });

  final WalletCardColors colors;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  /// Shown on the swatch when it is not selected (the "Otomatis" mark).
  final String? text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      selected: selected,
      semanticLabel: label,
      excludeChildSemantics: true,
      borderRadius: BorderRadius.circular(14),
      pressedScale: 0.92,
      child: AnimatedContainer(
        duration: Tokens.motion,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? p.textPrimary : const Color(0x00000000),
            width: 2.5,
          ),
        ),
        child: Container(
          width: 52,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: colors.gradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: selected
              ? const Icon(
                  RemixIcons.checkLine,
                  size: 20,
                  color: B4WalletCard.foreground,
                )
              : text == null
              ? null
              : Text(
                  text!,
                  style: context.text.labelLarge.copyWith(
                    color: B4WalletCard.foreground,
                  ),
                ),
        ),
      ),
    );
  }
}

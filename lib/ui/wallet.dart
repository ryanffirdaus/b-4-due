import 'package:flutter/widgets.dart';

import 'pressable.dart';
import 'theme.dart';
import 'tokens.dart';

/// A bill as a wallet card: a coloured diagonal gradient with white text
/// and icons. With [onTap] the whole card is a button.
class B4WalletCard extends StatelessWidget {
  const B4WalletCard({
    required this.colors,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.raised = false,
    super.key,
  });

  final WalletCardColors colors;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final double? height;
  final EdgeInsetsGeometry padding;

  /// A deeper shadow, for the card at the front of a stack.
  final bool raised;

  static const foreground = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(Tokens.cardRadius);
    final card = Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: colors.gradient,
        borderRadius: radius,
        boxShadow: [
          if (raised)
            BoxShadow(
              color: const Color(0xFF000000)
                  .withValues(alpha: p.isDark ? 0.45 : 0.16),
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
          BoxShadow(
            color: colors.end.withValues(alpha: p.isDark ? 0.3 : 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: foreground),
        child: IconTheme.merge(
          data: const IconThemeData(color: foreground),
          child: child,
        ),
      ),
    );
    if (onTap == null && onLongPress == null) return card;
    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      borderRadius: radius,
      pressedScale: 0.98,
      pressedOverlay: const Color(0x1A000000),
      child: card,
    );
  }
}

/// Cards stacked like a wallet: the first card is in front, fully shown;
/// the others peek out above it by [peek], showing their top row.
class B4WalletStack extends StatelessWidget {
  const B4WalletStack({
    required this.cards,
    required this.cardHeight,
    this.peek = 56,
    super.key,
  });

  /// Front card first.
  final List<Widget> cards;
  final double cardHeight;
  final double peek;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    final behind = cards.length - 1;
    return SizedBox(
      height: behind * peek + cardHeight,
      child: Stack(
        children: [
          // Back to front, so the first card is painted last.
          for (var i = behind; i >= 0; i--)
            Positioned(
              left: 0,
              right: 0,
              top: (behind - i) * peek,
              height: cardHeight,
              child: cards[i],
            ),
        ],
      ),
    );
  }
}

/// A small translucent pill on a wallet card ("TELAT 2 HARI", "HARI INI").
class B4CardBadge extends StatelessWidget {
  const B4CardBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x38000000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: context.text.labelMedium.copyWith(
          color: B4WalletCard.foreground,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Paid versus remaining as two rounded bars with a gap between them.
class B4ProgressBar extends StatelessWidget {
  const B4ProgressBar({required this.value, this.height = 6, super.key});

  /// 0 to 1.
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final v = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: v),
      duration: const Duration(milliseconds: 600),
      curve: Tokens.curve,
      builder: (context, t, _) {
        final done = (t * 1000).round();
        final left = 1000 - done;
        Widget bar(int flex, Color color) => Expanded(
          flex: flex,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        );
        return Row(
          children: [
            if (done > 0) bar(done, p.isDark ? p.accent : p.accentText),
            if (done > 0 && left > 0) const SizedBox(width: 4),
            if (left > 0) bar(left, p.surfaceVariant),
          ],
        );
      },
    );
  }
}

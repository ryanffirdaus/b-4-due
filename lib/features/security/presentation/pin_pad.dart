import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';

/// Large numeric keypad with PIN dots. Calls [onCompleted] when [length]
/// digits are entered (or on "OK" for variable-length entry).
class PinPad extends StatefulWidget {
  const PinPad({
    required this.onCompleted,
    this.minLength = 4,
    this.maxLength = 6,
    this.message,
    this.messageIsError = false,
    this.enabled = true,
    this.extraAction,
    super.key,
  });

  final Future<void> Function(String pin) onCompleted;
  final int minLength;
  final int maxLength;
  final String? message;
  final bool messageIsError;
  final bool enabled;

  /// Optional key in the bottom-left slot (e.g. biometric unlock).
  final Widget? extraAction;

  @override
  State<PinPad> createState() => PinPadState();
}

class PinPadState extends State<PinPad> {
  var _pin = '';
  var _busy = false;

  void clear() => setState(() => _pin = '');

  Future<void> _submit() async {
    if (_busy || _pin.length < widget.minLength) return;
    setState(() => _busy = true);
    final pin = _pin;
    try {
      await widget.onCompleted(pin);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _pin = '';
        });
      }
    }
  }

  void _press(String digit) {
    if (!widget.enabled || _busy || _pin.length >= widget.maxLength) return;
    HapticFeedback.selectionClick();
    setState(() => _pin += digit);
    // Fixed-length PINs submit themselves; 4-5 digit PINs use OK.
    if (_pin.length == widget.maxLength) _submit();
  }

  void _backspace() {
    if (_pin.isEmpty || _busy) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${_pin.length} / ${widget.maxLength}',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.maxLength; i++)
                AnimatedContainer(
                  duration: Tokens.motion,
                  curve: Tokens.curve,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: i < _pin.length ? 18 : 14,
                  height: i < _pin.length ? 18 : 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _pin.length ? p.primary : null,
                    border: Border.all(
                      color: i < _pin.length ? p.primary : p.outlineStrong,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 56,
          child: Center(
            child: widget.message == null
                ? null
                : Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium.copyWith(
                      color: widget.messageIsError
                          ? p.dangerText
                          : p.textSecondary,
                    ),
                  ),
          ),
        ),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final d in row) _Key(label: d, onTap: () => _press(d)),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(dimension: 88, child: widget.extraAction),
            _Key(label: '0', onTap: () => _press('0')),
            SizedBox.square(
              dimension: 88,
              child:
                  _pin.length >= widget.minLength &&
                      _pin.length < widget.maxLength
                  ? Center(
                      child: B4IconButton(
                        label: 'OK',
                        icon: RemixIcons.checkLine,
                        size: 30,
                        filled: true,
                        onPressed: _submit,
                      ),
                    )
                  : Center(
                      child: B4IconButton(
                        label: l10n.lockDelete,
                        icon: RemixIcons.deleteBack2Line,
                        size: 28,
                        onPressed: _backspace,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Pressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Tokens.cardRadius),
        pressedScale: 0.92,
        pressedOverlay: p.primary.withValues(alpha: 0.12),
        child: Container(
          width: 80,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Tokens.cardRadius),
            color: p.surface,
            border: Border.all(color: p.outline),
          ),
          child: Text(
            label,
            style: context.text.headlineLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

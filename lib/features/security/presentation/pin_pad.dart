import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';

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
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${_pin.length} / ${widget.maxLength}',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.maxLength; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _pin.length ? context.palette.primaryText : null,
                    border: Border.all(
                      color: i < _pin.length
                          ? context.palette.primaryText
                          : context.palette.textSecondary,
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: widget.messageIsError
                          ? context.palette.dangerText
                          : context.palette.textSecondary,
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
                  ? IconButton(
                      tooltip: 'OK',
                      iconSize: 32,
                      onPressed: _submit,
                      icon: Icon(
                        Icons.check,
                        color: context.palette.primaryText,
                      ),
                    )
                  : IconButton(
                      tooltip: l10n.lockDelete,
                      iconSize: 28,
                      onPressed: _backspace,
                      icon: const Icon(Icons.backspace_outlined),
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox.square(
        dimension: 72,
        child: Material(
          color: context.palette.card,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

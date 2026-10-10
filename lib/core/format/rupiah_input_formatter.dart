import 'package:flutter/services.dart';

import 'formatters.dart';

/// Keeps only digits and regroups them as the user types: "1250000" becomes
/// "1.250.000". The caret is kept at the end, which is where people type.
class RupiahInputFormatter extends TextInputFormatter {
  RupiahInputFormatter(this._formatters);

  final Formatters _formatters;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final value = parseRupiah(newValue.text);
    if (value == null) {
      // Either empty or too long; keep the previous text when too long.
      final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
      return digits.isEmpty ? TextEditingValue.empty : oldValue;
    }
    final text = _formatters.groupedNumber(value);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

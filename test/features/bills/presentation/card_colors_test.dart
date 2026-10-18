import 'package:b4due/features/bills/domain/bill_category.dart';
import 'package:b4due/features/bills/presentation/bill_labels.dart';
import 'package:b4due/ui/tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every category has a valid default card colour', () {
    for (final category in BillCategory.values) {
      expect(
        category.defaultCardColor,
        inInclusiveRange(0, Palette.walletCards.length - 1),
      );
    }
  });

  test('a chosen colour wins; none or a bad index follows the category', () {
    const electricity = BillCategory.electricity;
    final own = Palette.walletCards[electricity.defaultCardColor];
    expect(walletCardColors(2, electricity), Palette.walletCards[2]);
    expect(walletCardColors(null, electricity), own);
    expect(walletCardColors(99, electricity), own);
    expect(walletCardColors(-1, electricity), own);
  });
}

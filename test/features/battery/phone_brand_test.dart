import 'package:b4due/features/battery/domain/phone_brand.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps Build.MANUFACTURER values to OS families', () {
    const cases = {
      'Xiaomi': PhoneBrand.xiaomi,
      'Redmi': PhoneBrand.xiaomi,
      'POCO': PhoneBrand.xiaomi,
      'OPPO': PhoneBrand.oppo,
      'realme': PhoneBrand.oppo,
      'OnePlus': PhoneBrand.oppo,
      'vivo': PhoneBrand.vivo,
      'samsung': PhoneBrand.samsung,
      'INFINIX MOBILITY LIMITED': PhoneBrand.transsion,
      'TECNO': PhoneBrand.transsion,
      'HUAWEI': PhoneBrand.huawei,
      'Google': PhoneBrand.other,
      '': PhoneBrand.other,
    };
    cases.forEach((manufacturer, brand) {
      expect(
        PhoneBrand.fromManufacturer(manufacturer),
        brand,
        reason: manufacturer,
      );
    });
    expect(PhoneBrand.fromManufacturer(null), PhoneBrand.other);
  });
}

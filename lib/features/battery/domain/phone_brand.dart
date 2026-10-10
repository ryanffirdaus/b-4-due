/// Phone families that need different battery settings. Grouped by the OS
/// skin rather than the badge on the phone (realme and OnePlus run ColorOS,
/// Redmi and POCO run Xiaomi's MIUI/HyperOS, and so on).
enum PhoneBrand {
  xiaomi,
  oppo,
  vivo,
  samsung,
  transsion,
  huawei,
  other;

  /// Maps `Build.MANUFACTURER` to a family.
  static PhoneBrand fromManufacturer(String? manufacturer) {
    final m = (manufacturer ?? '').toLowerCase().trim();
    bool any(List<String> names) => names.any(m.contains);
    if (any(['xiaomi', 'redmi', 'poco'])) return PhoneBrand.xiaomi;
    if (any(['oppo', 'realme', 'oneplus'])) return PhoneBrand.oppo;
    if (any(['vivo', 'iqoo'])) return PhoneBrand.vivo;
    if (m.contains('samsung')) return PhoneBrand.samsung;
    if (any(['infinix', 'tecno', 'itel', 'transsion'])) {
      return PhoneBrand.transsion;
    }
    if (any(['huawei', 'honor'])) return PhoneBrand.huawei;
    return PhoneBrand.other;
  }
}

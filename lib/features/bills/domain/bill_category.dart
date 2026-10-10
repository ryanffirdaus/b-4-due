/// Bill categories. Stored by [name], so renaming a value is a breaking
/// change for databases and backups. Unknown names fall back to [other].
enum BillCategory {
  electricity,
  water,
  internet,
  phone,
  health,
  vehicleTax,
  installment,
  insurance,
  subscription,
  housing,
  education,
  other;

  static BillCategory fromName(String name) => BillCategory.values.firstWhere(
    (c) => c.name == name,
    orElse: () => BillCategory.other,
  );
}

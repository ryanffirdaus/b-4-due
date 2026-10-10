import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../bills/domain/bill_category.dart';
import '../../bills/domain/recurrence.dart';
import '../../currency/domain/money.dart';

/// A prefilled starting point for a common Indonesian bill.
///
/// Names are proper nouns or Indonesia-specific services, so they live here
/// rather than in the l10n files.
@immutable
class BillTemplate {
  const BillTemplate({
    required this.key,
    required this.name,
    required this.category,
    required this.recurrence,
    this.typicalDay,
    this.hint,
    this.currency = idr,
  });

  /// Stable identifier, independent of the display name.
  final String key;
  final String name;
  final BillCategory category;
  final Recurrence recurrence;

  /// Day of month the bill is usually due, if there is a common one.
  final int? typicalDay;

  /// Short tip shown as the default note.
  final String? hint;

  /// Currency the service usually bills in.
  final Currency currency;

  /// The first due date to suggest when the user picks this template on
  /// [today]: the next [typicalDay] on or after today, or a week from today.
  LocalDate suggestedDueDate(LocalDate today) {
    final day = typicalDay;
    if (day == null) return today.addDays(7);
    final thisMonth = LocalDate(
      today.year,
      today.month,
      1,
    ).addMonths(0, preferredDay: day);
    if (!thisMonth.isBefore(today)) return thisMonth;
    return thisMonth.addMonths(1, preferredDay: day);
  }
}

const billTemplates = <BillTemplate>[
  BillTemplate(
    key: 'pln',
    name: 'Listrik PLN',
    category: BillCategory.electricity,
    recurrence: Recurrence.monthly(),
    typicalDay: 20,
    hint: 'Pascabayar: bayar paling lambat tanggal 20.',
  ),
  BillTemplate(
    key: 'pdam',
    name: 'Air PDAM',
    category: BillCategory.water,
    recurrence: Recurrence.monthly(),
    typicalDay: 20,
  ),
  BillTemplate(
    key: 'internet',
    name: 'Internet rumah',
    category: BillCategory.internet,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'phone',
    name: 'Pulsa / paket pascabayar',
    category: BillCategory.phone,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'bpjs_kesehatan',
    name: 'BPJS Kesehatan',
    category: BillCategory.health,
    recurrence: Recurrence.monthly(),
    typicalDay: 10,
    hint: 'Iuran dibayar paling lambat tanggal 10 setiap bulan.',
  ),
  BillTemplate(
    key: 'bpjs_tk',
    name: 'BPJS Ketenagakerjaan',
    category: BillCategory.health,
    recurrence: Recurrence.monthly(),
    typicalDay: 15,
  ),
  BillTemplate(
    key: 'pkb',
    name: 'Pajak kendaraan (tahunan)',
    category: BillCategory.vehicleTax,
    recurrence: Recurrence.yearly(),
    hint: 'Lihat tanggal berlaku pajak di STNK.',
  ),
  BillTemplate(
    key: 'stnk_5y',
    name: 'Perpanjang STNK & ganti pelat (5 tahunan)',
    category: BillCategory.vehicleTax,
    recurrence: Recurrence.every5Years(),
    hint: 'Butuh cek fisik kendaraan. Bawa KTP dan BPKB asli.',
  ),
  BillTemplate(
    key: 'pbb',
    name: 'PBB (Pajak Bumi dan Bangunan)',
    category: BillCategory.housing,
    recurrence: Recurrence.yearly(),
    hint: 'Jatuh tempo tercantum di SPPT PBB.',
  ),
  BillTemplate(
    key: 'kpr',
    name: 'Cicilan KPR',
    category: BillCategory.installment,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'vehicle_loan',
    name: 'Cicilan kendaraan',
    category: BillCategory.installment,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'credit_card',
    name: 'Kartu kredit',
    category: BillCategory.installment,
    recurrence: Recurrence.monthly(),
    hint: 'Bayar minimal sebelum jatuh tempo agar tidak kena denda.',
  ),
  BillTemplate(
    key: 'paylater',
    name: 'Paylater',
    category: BillCategory.installment,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'insurance',
    name: 'Asuransi',
    category: BillCategory.insurance,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'rent',
    name: 'Sewa kos / kontrakan',
    category: BillCategory.housing,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'ipl',
    name: 'Iuran lingkungan (IPL)',
    category: BillCategory.housing,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'school',
    name: 'SPP sekolah',
    category: BillCategory.education,
    recurrence: Recurrence.monthly(),
    typicalDay: 10,
  ),
  BillTemplate(
    key: 'netflix',
    name: 'Netflix',
    category: BillCategory.subscription,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'spotify',
    name: 'Spotify',
    category: BillCategory.subscription,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'youtube_premium',
    name: 'YouTube Premium',
    category: BillCategory.subscription,
    recurrence: Recurrence.monthly(),
  ),
  BillTemplate(
    key: 'claude_pro',
    name: 'Claude Pro',
    category: BillCategory.subscription,
    recurrence: Recurrence.monthly(),
    currency: usd,
    hint: 'Ditagih dalam dolar; rupiah dihitung dari kurs hari ini.',
  ),
  BillTemplate(
    key: 'chatgpt_plus',
    name: 'ChatGPT Plus',
    category: BillCategory.subscription,
    recurrence: Recurrence.monthly(),
    currency: usd,
    hint: 'Ditagih dalam dolar; rupiah dihitung dari kurs hari ini.',
  ),
  BillTemplate(
    key: 'cloud_storage',
    name: 'Penyimpanan cloud (Google One / iCloud)',
    category: BillCategory.subscription,
    recurrence: Recurrence.monthly(),
  ),
];

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../calendar/calendar_providers.dart';
import '../../currency/currency_providers.dart';
import '../../settings/theme_controller.dart';
import '../data/backup_service.dart';
import '../domain/backup_codec.dart';
import 'csv_export.dart';

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    onRestored: ref.watch(onBillsChangedProvider),
  ),
);

/// Settings card: share/save/restore the JSON backup and export CSV.
class BackupSection extends ConsumerWidget {
  const BackupSection({super.key});

  String _fileStamp(WidgetRef ref) =>
      LocalDate.fromDateTime(ref.read(clockProvider)()).toIso();

  /// Writes [contents] to a temporary file for the share sheet.
  Future<XFile> _tempFile(String name, String contents) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    await file.writeAsString(contents, flush: true);
    return XFile(file.path, mimeType: 'application/json');
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final json = await ref.read(backupServiceProvider).exportJson();
    final file = await _tempFile(
      'b4due-cadangan-${_fileStamp(ref)}.json',
      json,
    );
    await SharePlus.instance.share(ShareParams(files: [file]));
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final toast = B4Toast.of(context);
    final json = await ref.read(backupServiceProvider).exportJson();
    final uri = await FilePicker.saveFile(
      fileName: 'b4due-cadangan-${_fileStamp(ref)}.json',
      bytes: utf8.encode(json),
      mimeType: 'application/json',
    );
    if (uri != null) toast.show(l10n.backupSaved);
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final toast = B4Toast.of(context);
    final service = ref.read(backupServiceProvider);

    final files = await FilePicker.pickFiles();
    if (files.isEmpty) return;

    final BackupData data;
    try {
      data = service.preview(utf8.decode(await files.first.readAsBytes()));
    } on BackupFormatException catch (e) {
      toast.error(_errorText(l10n, e));
      return;
    } on FormatException {
      toast.error(l10n.backupErrorNotJson);
      return;
    }
    if (!context.mounted) return;

    final confirmed = await showB4Confirm(
      context: context,
      title: l10n.backupRestoreConfirmTitle,
      body: l10n.backupRestoreConfirmBody(
        data.bills.where((b) => !b.isDeleted).length,
        data.payments.length,
        format.longDate(LocalDate.fromDateTime(data.exportedAt.toLocal())),
      ),
      confirmLabel: l10n.backupRestoreAction,
      destructive: true,
    );
    if (!confirmed) return;
    final orphanEvents = await service.restore(data);
    await ref.read(themePreferenceProvider.notifier).reload();
    await ref.read(accentProvider.notifier).reload();
    await ref.read(mainCurrencyProvider.notifier).reload();
    final calendar = ref.read(calendarGatewayProvider);
    for (final eventId in orphanEvents) {
      await calendar.deleteEvent(eventId);
    }
    toast.show(l10n.backupRestored);
  }

  Future<void> _csv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final main = context.mainCurrency;
    final data = await ref.read(backupServiceProvider).collect();
    final export = buildCsvExport(data, l10n, main: main);
    final stamp = _fileStamp(ref);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          await _tempFile('b4due-tagihan-$stamp.csv', export.bills),
          await _tempFile('b4due-riwayat-$stamp.csv', export.payments),
        ],
      ),
    );
  }

  static String _errorText(AppLocalizations l10n, BackupFormatException e) =>
      switch (e.reason) {
        BackupFormatError.notJson => l10n.backupErrorNotJson,
        BackupFormatError.notB4Due => l10n.backupErrorNotB4Due,
        BackupFormatError.newerVersion => l10n.backupErrorNewer,
        BackupFormatError.invalidData => l10n.backupErrorInvalid,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        B4ListGroup(
          children: [
            B4ListRow(
              icon: RemixIcons.shareForwardLine,
              title: l10n.backupExport,
              subtitle: l10n.backupExportHelp,
              onTap: () => _share(context, ref),
            ),
            B4ListRow(
              icon: RemixIcons.save3Line,
              title: l10n.backupSave,
              subtitle: l10n.backupSaveHelp,
              onTap: () => _save(context, ref),
            ),
            B4ListRow(
              icon: RemixIcons.arrowGoBackLine,
              title: l10n.backupRestore,
              subtitle: l10n.backupRestoreHelp,
              onTap: () => _restore(context, ref),
            ),
            B4ListRow(
              icon: RemixIcons.fileExcel2Line,
              title: l10n.backupCsv,
              subtitle: l10n.backupCsvHelp,
              onTap: () => _csv(context, ref),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
          child: Text(l10n.backupAutoInfo, style: context.text.bodySmall),
        ),
      ],
    );
  }
}

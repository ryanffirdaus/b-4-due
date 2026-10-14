import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../calendar/calendar_providers.dart';
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
    final messenger = ScaffoldMessenger.of(context);
    final json = await ref.read(backupServiceProvider).exportJson();
    final uri = await FilePicker.saveFile(
      fileName: 'b4due-cadangan-${_fileStamp(ref)}.json',
      bytes: utf8.encode(json),
      mimeType: 'application/json',
    );
    if (uri != null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupSaved)));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(backupServiceProvider);

    final files = await FilePicker.pickFiles();
    if (files.isEmpty) return;

    final BackupData data;
    try {
      data = service.preview(utf8.decode(await files.first.readAsBytes()));
    } on BackupFormatException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_errorText(l10n, e))));
      return;
    } on FormatException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupErrorNotJson)));
      return;
    }
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupRestoreConfirmTitle),
        content: Text(
          l10n.backupRestoreConfirmBody(
            data.bills.where((b) => !b.isDeleted).length,
            data.payments.length,
            format.longDate(LocalDate.fromDateTime(data.exportedAt.toLocal())),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.palette.dangerText,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.backupRestoreAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final orphanEvents = await service.restore(data);
    final calendar = ref.read(calendarGatewayProvider);
    for (final eventId in orphanEvents) {
      await calendar.deleteEvent(eventId);
    }
    messenger.showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
  }

  Future<void> _csv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final data = await ref.read(backupServiceProvider).collect();
    final export = buildCsvExport(data, l10n);
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

    Widget tile(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
    ) => ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              tile(
                Icons.ios_share,
                l10n.backupExport,
                l10n.backupExportHelp,
                () => _share(context, ref),
              ),
              const Divider(indent: 16),
              tile(
                Icons.save_alt,
                l10n.backupSave,
                l10n.backupSaveHelp,
                () => _save(context, ref),
              ),
              const Divider(indent: 16),
              tile(
                Icons.restore,
                l10n.backupRestore,
                l10n.backupRestoreHelp,
                () => _restore(context, ref),
              ),
              const Divider(indent: 16),
              tile(
                Icons.table_chart_outlined,
                l10n.backupCsv,
                l10n.backupCsvHelp,
                () => _csv(context, ref),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
          child: Text(
            l10n.backupAutoInfo,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.palette.textSecondary),
          ),
        ),
      ],
    );
  }
}

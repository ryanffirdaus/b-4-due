import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../backup/presentation/backup_section.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../reminders/domain/reminder_settings.dart';
import '../../reminders/reminder_providers.dart';
import '../../security/presentation/security_section.dart';

const _offsetChoices = [30, 14, 7, 3, 2, 1, 0];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _save(WidgetRef ref, ReminderSettings settings) async {
    await ref.read(settingsRepositoryProvider).saveReminderSettings(settings);
    await ref.read(onBillsChangedProvider)();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final theme = Theme.of(context);
    final settings =
        ref.watch(reminderSettingsProvider).value ?? const ReminderSettings();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Tokens.pagePadding,
            0,
            Tokens.pagePadding,
            Tokens.sectionGap,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: Tokens.cardGap),
              child: Text(
                l10n.navSettings,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            _Header(l10n.settingsPermissionsHeader),
            const _PermissionsCard(),
            const SizedBox(height: 12),
            _Header(l10n.settingsRemindersHeader),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsDefaultOffsets,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.settingsDefaultOffsetsHelp,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final offset in _offsetChoices)
                          FilterChip(
                            label: Text(offsetLabel(l10n, offset)),
                            selected: settings.defaultOffsets.contains(offset),
                            onSelected: (on) {
                              final next = ReminderSettings.normalizeOffsets(
                                on
                                    ? [...settings.defaultOffsets, offset]
                                    : settings.defaultOffsets.where(
                                        (o) => o != offset,
                                      ),
                              );
                              // Never allow "no reminders at all" by accident.
                              if (next.isEmpty) return;
                              _save(
                                ref,
                                settings.copyWith(defaultOffsets: next),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: Text(l10n.settingsDefaultTime),
                subtitle: Text(format.timeOfDay(settings.defaultMinuteOfDay)),
                onTap: () async {
                  final minute = settings.defaultMinuteOfDay;
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: minute ~/ 60,
                      minute: minute % 60,
                    ),
                  );
                  if (picked == null) return;
                  await _save(
                    ref,
                    settings.copyWith(
                      defaultMinuteOfDay: picked.hour * 60 + picked.minute,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _Header(l10n.securityHeader),
            const SecuritySection(),
            const SizedBox(height: 12),
            _Header(l10n.backupHeader),
            const BackupSection(),
          ],
        ),
      ),
    );
  }
}

/// Permission health plus "Tes notifikasi sekarang".
class _PermissionsCard extends ConsumerWidget {
  const _PermissionsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(reminderPermissionStatusProvider).value;
    final permissions = ref.read(reminderPermissionsProvider);

    Future<void> thenRefresh(Future<Object?> action) async {
      await action;
      ref.invalidate(reminderPermissionStatusProvider);
      await ref.read(onBillsChangedProvider)();
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (status != null) ...[
            _StatusTile(
              ok: status.notificationsAllowed,
              okText: l10n.settingsNotificationsAllowed,
              problemText: l10n.settingsNotificationsBlocked,
              onFix: () => thenRefresh(permissions.requestNotifications()),
            ),
            const Divider(indent: 16),
            _StatusTile(
              ok: status.exactAlarmsAllowed,
              okText: l10n.settingsExactAllowed,
              problemText: l10n.settingsExactBlocked,
              onFix: () => thenRefresh(permissions.requestExactAlarms()),
            ),
            const Divider(indent: 16),
          ],
          ListTile(
            leading: const Icon(Icons.battery_alert_outlined),
            title: Text(l10n.batterySettingsTile),
            subtitle: Text(l10n.batterySettingsTileHelp),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.battery),
          ),
          const Divider(indent: 16),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(l10n.settingsTestNotification),
            subtitle: Text(l10n.settingsTestNotificationHelp),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final current = await permissions.status();
              if (!current.notificationsAllowed) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.settingsTestNotificationBlocked)),
                );
                return;
              }
              await ref.read(reminderRuntimeProvider).gateway.showTest();
            },
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.ok,
    required this.okText,
    required this.problemText,
    required this.onFix,
  });

  final bool ok;
  final String okText;
  final String problemText;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle_outline : Icons.error_outline,
        color: ok ? context.palette.primaryText : context.palette.dangerText,
      ),
      title: Text(ok ? okText : problemText),
      onTap: ok ? null : onFix,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: context.palette.textSecondary),
        ),
      ),
    );
  }
}

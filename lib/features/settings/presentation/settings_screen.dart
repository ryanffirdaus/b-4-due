import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../backup/presentation/backup_section.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../budget/presentation/budget_section.dart';
import '../../currency/presentation/main_currency_section.dart';
import '../../reminders/domain/reminder_settings.dart';
import '../../reminders/reminder_providers.dart';
import '../../security/presentation/security_section.dart';
import 'theme_picker.dart';

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
    final settings =
        ref.watch(reminderSettingsProvider).value ?? const ReminderSettings();

    return B4Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: Tokens.fabClearance),
        children: [
          B4PageTitle(l10n.navSettings),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Tokens.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                B4GroupLabel(l10n.settingsPermissionsHeader),
                const _PermissionsCard(),
                B4GroupLabel(l10n.settingsAppearanceHeader),
                const ThemePicker(),
                B4GroupLabel(l10n.settingsCurrencyHeader),
                const MainCurrencySection(),
                B4GroupLabel(l10n.settingsBudgetHeader),
                const BudgetSection(),
                B4GroupLabel(l10n.settingsRemindersHeader),
                B4Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsDefaultOffsets,
                        style: context.text.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.settingsDefaultOffsetsHelp,
                        style: context.text.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final offset in _offsetChoices)
                            B4Chip(
                              label: offsetLabel(l10n, offset),
                              selected: settings.defaultOffsets.contains(
                                offset,
                              ),
                              onTap: () {
                                final on = !settings.defaultOffsets.contains(
                                  offset,
                                );
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
                const SizedBox(height: Tokens.listGap),
                B4ListGroup(
                  children: [
                    B4ListRow(
                      icon: RemixIcons.timeLine,
                      title: l10n.settingsDefaultTime,
                      subtitle: format.timeOfDay(settings.defaultMinuteOfDay),
                      showChevron: true,
                      onTap: () async {
                        final picked = await showB4TimePicker(
                          context: context,
                          title: l10n.settingsDefaultTime,
                          initialMinuteOfDay: settings.defaultMinuteOfDay,
                        );
                        if (picked == null) return;
                        await _save(
                          ref,
                          settings.copyWith(defaultMinuteOfDay: picked),
                        );
                      },
                    ),
                  ],
                ),
                B4GroupLabel(l10n.securityHeader),
                const SecuritySection(),
                B4GroupLabel(l10n.backupHeader),
                const BackupSection(),
              ],
            ),
          ),
        ],
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

    return B4ListGroup(
      children: [
        if (status != null) ...[
          _StatusRow(
            ok: status.notificationsAllowed,
            okText: l10n.settingsNotificationsAllowed,
            problemText: l10n.settingsNotificationsBlocked,
            onFix: () => thenRefresh(permissions.requestNotifications()),
          ),
          _StatusRow(
            ok: status.exactAlarmsAllowed,
            okText: l10n.settingsExactAllowed,
            problemText: l10n.settingsExactBlocked,
            onFix: () => thenRefresh(permissions.requestExactAlarms()),
          ),
        ],
        B4ListRow(
          icon: RemixIcons.battery2ChargeLine,
          title: l10n.batterySettingsTile,
          subtitle: l10n.batterySettingsTileHelp,
          showChevron: true,
          onTap: () => context.push(Routes.battery),
        ),
        B4ListRow(
          icon: RemixIcons.notification3Line,
          tone: B4Tone.primary,
          title: l10n.settingsTestNotification,
          subtitle: l10n.settingsTestNotificationHelp,
          onTap: () async {
            final toast = B4Toast.of(context);
            final current = await permissions.status();
            if (!current.notificationsAllowed) {
              toast.error(l10n.settingsTestNotificationBlocked);
              return;
            }
            await ref.read(reminderRuntimeProvider).gateway.showTest();
          },
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
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
    return B4ListRow(
      icon: ok ? RemixIcons.checkboxCircleLine : RemixIcons.errorWarningLine,
      tone: ok ? B4Tone.success : B4Tone.danger,
      title: ok ? okText : problemText,
      showChevron: !ok,
      onTap: ok ? null : onFix,
    );
  }
}

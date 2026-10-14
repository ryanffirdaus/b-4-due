import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bills/presentation/bill_labels.dart';
import '../domain/bill_template.dart';

/// First step of adding a bill: start blank or from a common template.
class TemplatePickerScreen extends StatelessWidget {
  const TemplatePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.templatesTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(
                Icons.edit_outlined,
                color: context.palette.primaryText,
              ),
              title: Text(l10n.templatesBlank),
              subtitle: Text(l10n.templatesBlankSubtitle),
              onTap: () => context.pushReplacement(Routes.newBill()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
            child: Semantics(
              header: true,
              child: Text(
                l10n.templatesHeader,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < billTemplates.length; i++) ...[
                  if (i > 0) const Divider(indent: 72),
                  _TemplateTile(template: billTemplates[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template});

  final BillTemplate template;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: Icon(template.category.icon, color: context.palette.textPrimary),
      title: Text(template.name),
      subtitle: Text(template.recurrence.label(l10n)),
      onTap: () =>
          context.pushReplacement(Routes.newBill(templateKey: template.key)),
    );
  }
}

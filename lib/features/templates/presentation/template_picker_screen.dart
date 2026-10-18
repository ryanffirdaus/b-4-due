import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../bills/presentation/bill_labels.dart';
import '../domain/bill_template.dart';

/// First step of adding a bill: start blank or from a common template.
class TemplatePickerScreen extends StatelessWidget {
  const TemplatePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return B4Scaffold(
      topBar: B4TopBar(title: l10n.templatesTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Tokens.pagePadding,
          8,
          Tokens.pagePadding,
          32,
        ),
        children: [
          B4ListGroup(
            children: [
              B4ListRow(
                icon: RemixIcons.pencilLine,
                tone: B4Tone.primary,
                title: l10n.templatesBlank,
                subtitle: l10n.templatesBlankSubtitle,
                showChevron: true,
                onTap: () => context.pushReplacement(Routes.newBill()),
              ),
            ],
          ),
          B4GroupLabel(l10n.templatesHeader),
          B4ListGroup(
            children: [
              for (final template in billTemplates)
                _TemplateRow(template: template),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({required this.template});

  final BillTemplate template;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return B4ListRow(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: walletCardColors(null, template.category).gradient,
          shape: BoxShape.circle,
        ),
        child: Icon(
          template.category.icon,
          size: 20,
          color: B4WalletCard.foreground,
        ),
      ),
      title: template.name,
      subtitle: template.recurrence.label(l10n),
      onTap: () =>
          context.pushReplacement(Routes.newBill(templateKey: template.key)),
    );
  }
}

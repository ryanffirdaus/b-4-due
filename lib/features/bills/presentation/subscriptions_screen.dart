import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/presentation/home_screen.dart';
import '../domain/bill_category.dart';
import 'bill_labels.dart';
import 'widgets/subscription_card.dart';

/// Every active bill, searchable and filterable by category.
class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  final _query = TextEditingController();
  BillCategory? _category;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showB4OptionSheet<BillCategory?>(
      context: context,
      title: l10n.subsFilter,
      selected: _category,
      options: [
        B4Option(null, l10n.subsAllCategories, icon: RemixIcons.apps2Line),
        for (final c in BillCategory.values)
          B4Option(c, c.label(l10n), icon: c.icon),
      ],
    );
    if (picked == null) return;
    setState(() => _category = picked.value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final today = ref.watch(todayProvider);
    final bills = ref.watch(activeBillsProvider).value ?? const [];
    final query = _query.text.trim().toLowerCase();
    final visible = bills.where((b) {
      if (_category != null && b.category != _category) return false;
      if (query.isEmpty) return true;
      return b.name.toLowerCase().contains(query) ||
          b.category.label(l10n).toLowerCase().contains(query);
    }).toList();

    return B4Scaffold(
      floatingAction: B4TicketButton(
        icon: RemixIcons.addLine,
        label: l10n.homeAddBill,
        onPressed: () => context.push(Routes.addBill),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: B4PageTitle(l10n.navSubscriptions)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: Tokens.pagePadding,
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: B4SearchField(
                controller: _query,
                hint: l10n.subsSearchHint,
                onChanged: (_) => setState(() {}),
                trailing: B4IconButton(
                  icon: RemixIcons.equalizer2Line,
                  label: l10n.subsFilter,
                  color: _category == null ? null : p.primaryText,
                  filled: _category != null,
                  onPressed: _pickCategory,
                ),
              ),
            ),
          ),
          if (_category != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Tokens.pagePadding,
                4,
                Tokens.pagePadding,
                4,
              ),
              sliver: SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: B4FilterTag(
                    label: _category!.label(l10n),
                    icon: _category!.icon,
                    removeLabel: l10n.subsFilterRemove,
                    onRemove: () => setState(() => _category = null),
                  ),
                ),
              ),
            ),
          if (bills.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: EmptyBills()),
            )
          else if (visible.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(Tokens.pagePadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  l10n.subsNoResults,
                  style: context.text.bodyLarge.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              // Room for the floating button.
              padding: const EdgeInsets.fromLTRB(
                Tokens.pagePadding,
                8,
                Tokens.pagePadding,
                104,
              ),
              sliver: SliverList.separated(
                itemCount: visible.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: Tokens.listGap),
                itemBuilder: (context, i) =>
                    SubscriptionCard(bill: visible[i], today: today),
              ),
            ),
        ],
      ),
    );
  }
}

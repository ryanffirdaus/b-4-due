import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/shell.dart';
import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    final picked = await showModalBottomSheet<Object>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l10n.subsFilter,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.apps_rounded),
              title: Text(l10n.subsAllCategories),
              selected: _category == null,
              onTap: () => Navigator.pop(context, 'all'),
            ),
            for (final c in BillCategory.values)
              ListTile(
                leading: Icon(c.icon),
                title: Text(c.label(l10n)),
                selected: _category == c,
                onTap: () => Navigator.pop(context, c),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _category = picked is BillCategory ? picked : null);
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

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.addBill),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.homeAddBill),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: TabTitle(l10n.navSubscriptions)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: Tokens.pagePadding,
                vertical: 8,
              ),
              sliver: SliverToBoxAdapter(
                child: SearchBar(
                  controller: _query,
                  hintText: l10n.subsSearchHint,
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(p.surfaceVariant),
                  shape: const WidgetStatePropertyAll(StadiumBorder()),
                  leading: const Icon(Icons.search_rounded),
                  trailing: [
                    IconButton(
                      tooltip: l10n.subsFilter,
                      isSelected: _category != null,
                      onPressed: _pickCategory,
                      icon: const Icon(Icons.tune_rounded),
                      selectedIcon: Icon(
                        Icons.tune_rounded,
                        color: p.primaryText,
                      ),
                    ),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            if (_category != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Tokens.pagePadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InputChip(
                      label: Text(_category!.label(l10n)),
                      avatar: Icon(_category!.icon, size: 18),
                      onDeleted: () => setState(() => _category = null),
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
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: p.textSecondary),
                  ),
                ),
              )
            else
              SliverPadding(
                // Room for the FAB.
                padding: const EdgeInsets.fromLTRB(
                  Tokens.pagePadding,
                  8,
                  Tokens.pagePadding,
                  96,
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../../menu/data/menu_repository.dart';

/// Admin menu manager. Pick a business, then either paste a menu link OR
/// build a structured menu grouped by categories (both can coexist — the
/// customer app shows the structured menu when it has items, otherwise the
/// link).
class AdminMenusScreen extends ConsumerStatefulWidget {
  const AdminMenusScreen({super.key});

  @override
  ConsumerState<AdminMenusScreen> createState() => _AdminMenusScreenState();
}

class _AdminMenusScreenState extends ConsumerState<AdminMenusScreen> {
  Company? _company;
  final TextEditingController _link = TextEditingController();
  bool _savingLink = false;

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  void _selectCompany(Company? c) {
    setState(() {
      _company = c;
      _link.text = c?.menuUrl ?? '';
    });
  }

  Future<void> _saveLink() async {
    if (_company == null) return;
    setState(() => _savingLink = true);
    try {
      await ref.read(companiesRepositoryProvider).updateCompany(
        _company!.id,
        <String, dynamic>{'menuUrl': _link.text.trim()},
      );
      ref.invalidate(companiesProvider);
      _snack(ref.read(sProvider).menuLinkSaved);
    } catch (e) {
      _snack('${ref.read(sProvider).failed}: $e', error: true);
    } finally {
      if (mounted) setState(() => _savingLink = false);
    }
  }

  Future<void> _addItem() async {
    if (_company == null) return;
    final _NewItem? item = await showModalBottomSheet<_NewItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (BuildContext _) => const _AddItemSheet(),
    );
    if (item == null) return;
    try {
      await ref.read(menuRepositoryProvider).add(
            companyId: _company!.id,
            category: item.category,
            name: item.name,
            description: item.description,
            price: item.price,
          );
      ref.invalidate(companyMenuProvider(_company!.id));
    } catch (e) {
      if (mounted) _snack('${ref.read(sProvider).failed}: $e', error: true);
    }
  }

  Future<void> _deleteItem(MenuItem m) async {
    try {
      await ref.read(menuRepositoryProvider).delete(m.id);
      ref.invalidate(companyMenuProvider(_company!.id));
    } catch (e) {
      _snack('${ref.read(sProvider).deleteFailed}: $e', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<Company>> companies = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.menus)),
      floatingActionButton: _company == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _addItem,
              icon: const Icon(Icons.add_rounded),
              label: Text(s.addFood),
            ),
      body: companies.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          title: s.notLoaded,
          subtitle: e.toString(),
          icon: AppIcons.error,
        ),
        data: (List<Company> list) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: <Widget>[
              DropdownButtonFormField<Company>(
                initialValue: _company,
                decoration: InputDecoration(
                  labelText: s.selectBusiness,
                ),
                items: list
                    .map((Company c) => DropdownMenuItem<Company>(
                          value: c,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: _selectCompany,
              ),
              if (_company != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xl),
                Text(s.menuLink, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  s.menuLinkDesc,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _link,
                        decoration: const InputDecoration(
                          hintText: 'https://...',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton(
                      onPressed: _savingLink ? null : _saveLink,
                      child: Text(s.saveShort),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Text(s.structuredMenu,
                    style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                _MenuItems(
                  companyId: _company!.id,
                  onDelete: _deleteItem,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MenuItems extends ConsumerWidget {
  const _MenuItems({required this.companyId, required this.onDelete});

  final String companyId;
  final Future<void> Function(MenuItem) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<MenuItem>> async =
        ref.watch(companyMenuProvider(companyId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object e, _) => Text('${s.error}: $e', style: AppTextStyles.bodySm),
      data: (List<MenuItem> items) {
        if (items.isEmpty) {
          return Text(
            s.noFoodYet,
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.textSecondary),
          );
        }
        // Group by category, preserving order.
        final Map<String, List<MenuItem>> byCat =
            <String, List<MenuItem>>{};
        for (final MenuItem m in items) {
          byCat.putIfAbsent(m.category, () => <MenuItem>[]).add(m);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final MapEntry<String, List<MenuItem>> e in byCat.entries)
              ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: AppSpacing.md, bottom: AppSpacing.sm),
                  child: Text(e.key,
                      style: AppTextStyles.overline
                          .copyWith(color: AppColors.primary)),
                ),
                for (final MenuItem m in e.value)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(m.name,
                                  style: AppTextStyles.bodyLg
                                      .copyWith(fontWeight: FontWeight.w600)),
                              if ((m.description ?? '').isNotEmpty)
                                Text(m.description!,
                                    style: AppTextStyles.caption,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        if (m.price != null)
                          Text('${m.price!.toStringAsFixed(2)} ₼',
                              style: AppTextStyles.bodySm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              )),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.error),
                          onPressed: () => onDelete(m),
                        ),
                      ],
                    ),
                  ),
              ],
          ],
        );
      },
    );
  }
}

class _NewItem {
  const _NewItem({
    required this.category,
    required this.name,
    this.description,
    this.price,
  });
  final String category;
  final String name;
  final String? description;
  final double? price;
}

class _AddItemSheet extends ConsumerStatefulWidget {
  const _AddItemSheet();

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  final TextEditingController _category = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _price = TextEditingController();

  @override
  void dispose() {
    _category.dispose();
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  void _submit() {
    if (_category.text.trim().isEmpty || _name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(sProvider).categoryAndNameRequired)),
      );
      return;
    }
    Navigator.of(context).pop(_NewItem(
      category: _category.text.trim(),
      name: _name.text.trim(),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      price: double.tryParse(_price.text.trim().replaceAll(',', '.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final EdgeInsets bottom = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: bottom,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(s.addFood, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _category,
              decoration: InputDecoration(
                labelText: s.categoryLabel,
                hintText: s.categoryHint,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: s.name),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _description,
              decoration:
                  InputDecoration(labelText: s.descriptionOptionalField),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: s.priceOptional,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(s.add),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../menu/data/menu_repository.dart';
import '../../../core/utils/money.dart';
import '../../companies/application/companies_providers.dart';

/// The owner's own menu, via the owner-scoped `/api/v1/business/menu`
/// endpoints (the server resolves the company from the caller).
final AutoDisposeFutureProvider<List<MenuItem>> _myMenuProvider =
    FutureProvider.autoDispose<List<MenuItem>>((Ref ref) async {
  final List<dynamic> raw = await ref
      .read(apiClientProvider)
      .get<List<dynamic>>('/api/v1/business/menu');
  return raw
      .cast<Map<String, dynamic>>()
      .map(MenuItem.fromJson)
      .toList(growable: false);
});

/// Business → "Menyu": list grouped by category, add / edit / delete.
class BusinessMenuScreen extends ConsumerWidget {
  const BusinessMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<MenuItem>> menu = ref.watch(_myMenuProvider);
    // Prices are shown in the venue's own currency (₼ / ₺).
    final String currency =
        ref.watch(myCompanyProvider).valueOrNull?.currency ?? 'AZN';

    return Scaffold(
      appBar: AppBar(title: Text(s.menuWord)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref, null),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.addFood),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_myMenuProvider),
        child: menu.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => ListView(
            children: <Widget>[
              EmptyState(title: s.notLoaded, subtitle: '$e'),
            ],
          ),
          data: (List<MenuItem> items) {
            if (items.isEmpty) {
              return ListView(
                children: <Widget>[
                  EmptyState(
                    title: s.noFoodYet,
                    subtitle: s.menuOwnerHint,
                    icon: Icons.restaurant_menu_rounded,
                  ),
                ],
              );
            }
            final Map<String, List<MenuItem>> byCat =
                <String, List<MenuItem>>{};
            for (final MenuItem m in items) {
              byCat.putIfAbsent(m.category, () => <MenuItem>[]).add(m);
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 96),
              children: <Widget>[
                for (final MapEntry<String, List<MenuItem>> e
                    in byCat.entries) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppSpacing.lg, bottom: AppSpacing.sm),
                    child: Text(e.key.toUpperCase(),
                        style: AppTextStyles.overline
                            .copyWith(color: AppColors.caramelText)),
                  ),
                  for (final MenuItem m in e.value)
                    Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        title: Text(m.name,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w600)),
                        subtitle: (m.description ?? '').isEmpty
                            ? null
                            : Text(m.description!,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (m.price != null)
                              Text(Money.format(m.price!, currency),
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.caramelText,
                                  )),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  color: AppColors.dangerText),
                              tooltip: s.delete,
                              onPressed: () => _delete(context, ref, m),
                            ),
                          ],
                        ),
                        onTap: () => _openForm(context, ref, m),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, MenuItem m) async {
    final S s = ref.read(sProvider);
    final bool ok = await showConfirmSheet(
      context,
      title: '${s.delete}: ${m.name}?',
      body: s.menuDeleteBody,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok) return;
    try {
      await ref.read(apiClientProvider).delete('/api/v1/business/menu/${m.id}');
      ref.invalidate(_myMenuProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${s.deleteFailed}: $e')));
      }
    }
  }

  Future<void> _openForm(
      BuildContext context, WidgetRef ref, MenuItem? existing) async {
    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (BuildContext _) => _MenuItemForm(existing: existing),
    );
    if (saved ?? false) ref.invalidate(_myMenuProvider);
  }
}

class _MenuItemForm extends ConsumerStatefulWidget {
  const _MenuItemForm({this.existing});

  final MenuItem? existing;

  @override
  ConsumerState<_MenuItemForm> createState() => _MenuItemFormState();
}

class _MenuItemFormState extends ConsumerState<_MenuItemForm> {
  late final TextEditingController _cat =
      TextEditingController(text: widget.existing?.category ?? '');
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _desc =
      TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _price = TextEditingController(
      text: widget.existing?.price?.toStringAsFixed(2) ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _cat.dispose();
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final S s = ref.read(sProvider);
    if (_cat.text.trim().isEmpty || _name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.categoryAndNameRequired)));
      return;
    }
    final double? price =
        double.tryParse(_price.text.trim().replaceAll(',', '.'));
    final Map<String, dynamic> body = <String, dynamic>{
      'category': _cat.text.trim(),
      'name': _name.text.trim(),
      'description': _desc.text.trim(),
      'price': price,
    };
    setState(() => _saving = true);
    try {
      final ApiClient api = ref.read(apiClientProvider);
      if (widget.existing == null) {
        await api.post<dynamic>('/api/v1/business/menu', body: body);
      } else {
        await api.put<dynamic>('/api/v1/business/menu/${widget.existing!.id}',
            body: body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${s.failed}: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: MediaQuery.viewInsetsOf(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(widget.existing == null ? s.addFood : s.edit,
                style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _cat,
              decoration: InputDecoration(
                  labelText: s.categoryLabel, hintText: s.categoryHint),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _name,
              decoration: InputDecoration(hintText: s.hintMenuItemName, labelText: s.name),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _desc,
              maxLines: 2,
              decoration:
                  InputDecoration(hintText: s.hintMenuItemDesc, labelText: s.descriptionOptionalField),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(hintText: s.hintPrice, labelText: s.priceOptional),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(s.saveShort),
            ),
          ],
        ),
      ),
    );
  }
}

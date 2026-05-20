import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';

class AdminBusinessesScreen extends ConsumerStatefulWidget {
  const AdminBusinessesScreen({super.key});

  @override
  ConsumerState<AdminBusinessesScreen> createState() =>
      _AdminBusinessesScreenState();
}

class _AdminBusinessesScreenState
    extends ConsumerState<AdminBusinessesScreen> {
  final TextEditingController _search = TextEditingController();
  bool _loading = true;
  String? _error;
  final List<AdminCompany> _items = <AdminCompany>[];
  int _page = 0;
  int _totalPages = 1;
  int _total = 0;
  final Set<String> _busy = <String>{};

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 0;
      });
    }
    try {
      final AdminPage<AdminCompany> p =
          await ref.read(adminRepositoryProvider).companies(
                q: _search.text.trim(),
                page: _page,
              );
      setState(() {
        if (reset) _items.clear();
        _items.addAll(p.content);
        _totalPages = p.totalPages;
        _total = p.totalElements;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_page + 1 >= _totalPages) return;
    setState(() => _page++);
    await _load();
  }

  Future<void> _toggleFeatured(AdminCompany c, bool value) async {
    setState(() => _busy.add(c.id));
    try {
      final AdminCompany updated = await ref
          .read(adminRepositoryProvider)
          .setCompanyFeatured(c.id, value);
      final int idx = _items.indexWhere((AdminCompany e) => e.id == c.id);
      if (idx != -1) setState(() => _items[idx] = updated);
      ref.invalidate(adminStatsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Alınmadı: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(c.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl,
                  AppSpacing.xl, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child:
                              Text('Bizneslər', style: AppTextStyles.h1)),
                      Text('$_total', style: AppTextStyles.bodySm),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _load(reset: true),
                    decoration: InputDecoration(
                      hintText: 'Biznes adı axtar',
                      prefixIcon: const Icon(AppIcons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(AppIcons.search),
                        onPressed: () => _load(reset: true),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return EmptyState(
          title: 'Yüklənmədi', subtitle: _error, icon: AppIcons.error);
    }
    if (_items.isEmpty) {
      return const EmptyState(
        title: 'Tapılmadı',
        subtitle: 'Axtarışı dəyişib yenidən cəhd et.',
        icon: AppIcons.searchOff,
      );
    }
    final bool canLoadMore = _page + 1 < _totalPages;
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.huge),
        itemCount: _items.length + (canLoadMore ? 1 : 0),
        itemBuilder: (BuildContext ctx, int i) {
          if (i >= _items.length) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: OutlinedButton(
                  onPressed: _loading ? null : _loadMore,
                  child: Text(_loading ? 'Yüklənir...' : 'Daha çox'),
                ),
              ),
            );
          }
          final AdminCompany c = _items[i];
          return _CompanyTile(
            company: c,
            busy: _busy.contains(c.id),
            onFeatured: (bool v) => _toggleFeatured(c, v),
          );
        },
      ),
    );
  }
}

class _CompanyTile extends StatelessWidget {
  const _CompanyTile({
    required this.company,
    required this.busy,
    required this.onFeatured,
  });

  final AdminCompany company;
  final bool busy;
  final ValueChanged<bool> onFeatured;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child:
                  const Icon(AppIcons.store, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(company.name,
                      style: AppTextStyles.bodyLg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    company.ownerEmail ?? company.tagline ?? company.category,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (company.rating != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: <Widget>[
                          const Icon(AppIcons.star,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            '${company.rating!.toStringAsFixed(1)} · ${company.reviewCount} rəy',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Text('Seçilmiş', style: AppTextStyles.caption),
                busy
                    ? const SizedBox(
                        width: 40,
                        height: 24,
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : Switch(
                        value: company.featured,
                        onChanged: onFeatured,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

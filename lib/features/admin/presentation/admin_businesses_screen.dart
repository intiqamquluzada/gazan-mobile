import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';
import 'admin_widgets.dart';

class AdminBusinessesScreen extends ConsumerStatefulWidget {
  const AdminBusinessesScreen({super.key});

  @override
  ConsumerState<AdminBusinessesScreen> createState() =>
      _AdminBusinessesScreenState();
}

class _AdminBusinessesScreenState extends ConsumerState<AdminBusinessesScreen> {
  final TextEditingController _search = TextEditingController();
  bool _loading = true;
  String? _error;
  final List<AdminCompany> _items = <AdminCompany>[];
  int _page = 0;
  int _totalPages = 1;
  int _total = 0;
  final Set<String> _busy = <String>{};
  String? _status; // null = all

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
                status: _status,
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
          content: Text('${ref.read(sProvider).failed}: $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(c.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child:
                              Text(s.businessesTitle, style: AppTextStyles.h1)),
                      Text('$_total', style: AppTextStyles.bodySm),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _load(reset: true),
                    decoration: InputDecoration(
                      hintText: s.searchBusinessName,
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
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: <Widget>[
                      _statusChip(s.all, null),
                      _statusChip(s.statusPending, 'PENDING'),
                      _statusChip(s.statusApproved, 'APPROVED'),
                      _statusChip(s.statusSuspended, 'SUSPENDED'),
                    ],
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

  Widget _statusChip(String label, String? status) => ChoiceChip(
        label: Text(label),
        selected: _status == status,
        onSelected: (_) {
          setState(() => _status = status);
          _load(reset: true);
        },
      );

  Widget _body() {
    final S s = ref.read(sProvider);
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return EmptyState(
          title: s.notLoaded, subtitle: _error, icon: AppIcons.error);
    }
    if (_items.isEmpty) {
      return EmptyState(
        title: s.notFound,
        subtitle: s.searchTryAgain,
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
                  child: Text(_loading ? s.loading : s.loadMore),
                ),
              ),
            );
          }
          final AdminCompany c = _items[i];
          return _CompanyTile(
            company: c,
            busy: _busy.contains(c.id),
            onFeatured: (bool v) => _toggleFeatured(c, v),
            onOpen: () async {
              await context.push<void>('/admin/businesses/${c.id}');
              if (mounted) await _load(reset: true);
            },
          );
        },
      ),
    );
  }
}

class _CompanyTile extends ConsumerWidget {
  const _CompanyTile({
    required this.company,
    required this.busy,
    required this.onFeatured,
    required this.onOpen,
  });

  final AdminCompany company;
  final bool busy;
  final ValueChanged<bool> onFeatured;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppRadius.lg),
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
                color: AppColors.caramelSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child:
                  const Icon(AppIcons.store, color: AppColors.action, size: 22),
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
                  CompanyStatusBadge(status: company.status),
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
                              size: 14, color: AppColors.reward),
                          const SizedBox(width: 2),
                          Text(
                            '${company.rating!.toStringAsFixed(1)} · ${company.reviewCount} ${s.reviewWord}',
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
                Text(s.featuredLabel, style: AppTextStyles.caption),
                busy
                    ? const SizedBox(
                        width: 40,
                        height: 24,
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
      ),
    );
  }
}

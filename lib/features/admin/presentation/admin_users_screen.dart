import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';
import 'admin_widgets.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _search = TextEditingController();
  String? _roleFilter; // null = all
  bool _loading = true;
  String? _error;
  final List<AdminUser> _users = <AdminUser>[];
  int _page = 0;
  int _totalPages = 1;
  int _total = 0;

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
      final AdminPage<AdminUser> p =
          await ref.read(adminRepositoryProvider).users(
                q: _search.text.trim(),
                role: _roleFilter,
                page: _page,
              );
      setState(() {
        if (reset) _users.clear();
        _users.addAll(p.content);
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

  void _setFilter(String? role) {
    setState(() => _roleFilter = role);
    _load(reset: true);
  }

  Future<void> _openActions(AdminUser u) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) => _UserActionsSheet(
        user: u,
        onChangeRole: (String role) => _changeRole(u, role),
        onToggleActive: () => _toggleActive(u),
      ),
    );
  }

  Future<void> _changeRole(AdminUser u, String role) async {
    Navigator.of(context).pop();
    try {
      await ref.read(adminRepositoryProvider).setUserRole(u.id, role);
      _snack('${u.email} → ${roleLabel(role)}');
      await _load(reset: true);
      ref.invalidate(adminStatsProvider);
    } catch (e) {
      _snack('Alınmadı: $e', error: true);
    }
  }

  Future<void> _toggleActive(AdminUser u) async {
    Navigator.of(context).pop();
    try {
      await ref.read(adminRepositoryProvider).setUserActive(u.id, !u.active);
      _snack(u.active ? '${u.email} bloklandı' : '${u.email} aktivləşdi');
      await _load(reset: true);
    } catch (e) {
      _snack('Alınmadı: $e', error: true);
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
                          child: Text('İstifadəçilər',
                              style: AppTextStyles.h1)),
                      Text('$_total',
                          style: AppTextStyles.bodySm),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _load(reset: true),
                    decoration: InputDecoration(
                      hintText: 'Ad və ya e-poçt axtar',
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
                      _filterChip('Hamısı', null),
                      _filterChip('Müştəri', 'CUSTOMER'),
                      _filterChip('Biznes', 'BUSINESS_OWNER'),
                      _filterChip('Admin', 'ADMIN'),
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

  Widget _filterChip(String label, String? role) {
    final bool selected = _roleFilter == role;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _setFilter(role),
    );
  }

  Widget _body() {
    if (_loading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _users.isEmpty) {
      return EmptyState(
          title: 'Yüklənmədi', subtitle: _error, icon: AppIcons.error);
    }
    if (_users.isEmpty) {
      return const EmptyState(
        title: 'Tapılmadı',
        subtitle: 'Filtri dəyişib yenidən cəhd et.',
        icon: AppIcons.searchOff,
      );
    }
    final bool canLoadMore = _page + 1 < _totalPages;
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.huge),
        itemCount: _users.length + (canLoadMore ? 1 : 0),
        itemBuilder: (BuildContext ctx, int i) {
          if (i >= _users.length) {
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
          return _UserTile(
              user: _users[i], onTap: () => _openActions(_users[i]));
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onTap});

  final AdminUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.sm,
            ),
            child: Row(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Avatar(
                        name: user.fullName.isEmpty
                            ? user.email
                            : user.fullName,
                        size: 44),
                    if (!user.active)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface,
                                width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.fullName.isEmpty ? '(adsız)' : user.fullName,
                        style: AppTextStyles.bodyLg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(user.email,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AdminRoleBadge(role: user.role),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserActionsSheet extends StatelessWidget {
  const _UserActionsSheet({
    required this.user,
    required this.onChangeRole,
    required this.onToggleActive,
  });

  final AdminUser user;
  final ValueChanged<String> onChangeRole;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(user.fullName.isEmpty ? user.email : user.fullName,
                style: AppTextStyles.h3),
            Text(user.email, style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.lg),
            Text('Rol təyin et', style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: <Widget>[
                for (final String r in const <String>[
                  'CUSTOMER',
                  'BUSINESS_OWNER',
                  'ADMIN'
                ])
                  ChoiceChip(
                    label: Text(roleLabel(r)),
                    selected: user.role == r,
                    onSelected:
                        user.role == r ? null : (_) => onChangeRole(r),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onToggleActive,
                icon: Icon(user.active ? Icons.block_rounded : AppIcons.check),
                label: Text(user.active
                    ? 'İstifadəçini blokla'
                    : 'İstifadəçini aktivləşdir'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      user.active ? AppColors.error : AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';
import 'admin_user_detail_screen.dart';
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
      useRootNavigator: true,
      showDragHandle: true,
      builder: (BuildContext ctx) => _UserActionsSheet(
        user: u,
        onChangeRole: (String role) => _changeRole(u, role),
        onToggleActive: () => _toggleActive(u),
        onDetail: () {
          Navigator.of(ctx).pop();
          context.go('/admin/users/${u.id}');
        },
        onResetPassword: () async {
          Navigator.of(ctx).pop();
          final bool? done = await showAdminResetPassword(context, u.id);
          if (done == true) {
            _snack(ref.read(sProvider).passwordResetDone);
          }
        },
      ),
    );
  }

  Future<void> _changeRole(AdminUser u, String role) async {
    Navigator.of(context).pop();
    try {
      await ref.read(adminRepositoryProvider).setUserRole(u.id, role);
      _snack('${u.email} → ${roleLabel(ref.read(sProvider), role)}');
      await _load(reset: true);
      ref.invalidate(adminStatsProvider);
    } catch (e) {
      _snack('${ref.read(sProvider).failed}: $e', error: true);
    }
  }

  Future<void> _toggleActive(AdminUser u) async {
    Navigator.of(context).pop();
    final S s = ref.read(sProvider);
    try {
      await ref.read(adminRepositoryProvider).setUserActive(u.id, !u.active);
      _snack(u.active
          ? '${u.email} ${s.userBlocked}'
          : '${u.email} ${s.userActivated}');
      await _load(reset: true);
    } catch (e) {
      _snack('${s.failed}: $e', error: true);
    }
  }

  Future<void> _openCreate() async {
    final bool? created = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _CreateUserSheet(),
    );
    if (created == true) {
      await _load(reset: true);
      ref.invalidate(adminStatsProvider);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.person_add_alt_rounded),
        label: Text(s.createUserAction),
      ),
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
                          child: Text(s.usersTitle, style: AppTextStyles.h1)),
                      Text('$_total', style: AppTextStyles.bodySm),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _load(reset: true),
                    decoration: InputDecoration(
                      hintText: s.searchNameEmail,
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
                      _filterChip(s.all, null),
                      _filterChip(s.roleCustomer, 'CUSTOMER'),
                      _filterChip(s.roleBusiness, 'BUSINESS_OWNER'),
                      _filterChip(s.roleCashier, 'CASHIER'),
                      _filterChip(s.roleAdmin, 'ADMIN'),
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
    final S s = ref.read(sProvider);
    if (_loading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _users.isEmpty) {
      return EmptyState(
          title: s.notLoaded, subtitle: _error, icon: AppIcons.error);
    }
    if (_users.isEmpty) {
      return EmptyState(
        title: s.notFound,
        subtitle: s.filterTryAgain,
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
                  child: Text(_loading ? s.loading : s.loadMore),
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

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user, required this.onTap});

  final AdminUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
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
                        name:
                            user.fullName.isEmpty ? user.email : user.fullName,
                        size: 44),
                    if (!user.active)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
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
                        user.fullName.isEmpty ? s.unnamed : user.fullName,
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

class _CreateUserSheet extends ConsumerStatefulWidget {
  const _CreateUserSheet();

  @override
  ConsumerState<_CreateUserSheet> createState() => _CreateUserSheetState();
}

class _CreateUserSheetState extends ConsumerState<_CreateUserSheet> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String _role = 'BUSINESS_OWNER';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(adminRepositoryProvider).createUser(
            email: _email.text.trim(),
            password: _password.text,
            fullName: _name.text.trim(),
            phone: _phone.text.trim(),
            role: _role,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl,
          AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(s.createUserAction, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: s.fullName),
                validator: (String? v) => (v == null || v.trim().length < 2)
                    ? s.enterNameShort
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: s.email),
                validator: (String? v) =>
                    (v == null || !v.contains('@')) ? s.invalidEmail : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: s.phone, hintText: '+994501234567'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(labelText: s.password),
                validator: (String? v) =>
                    (v == null || v.length < 8) ? s.pwErrMin8 : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: <Widget>[
                  for (final String r in const <String>[
                    'CUSTOMER',
                    'BUSINESS_OWNER',
                    'ADMIN',
                  ])
                    ChoiceChip(
                      label: Text(roleLabel(s, r)),
                      selected: _role == r,
                      onSelected: (_) => setState(() => _role = r),
                    ),
                ],
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: AppTextStyles.bodySm),
              ],
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(s.saveShort),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserActionsSheet extends ConsumerWidget {
  const _UserActionsSheet({
    required this.user,
    required this.onChangeRole,
    required this.onToggleActive,
    required this.onDetail,
    required this.onResetPassword,
  });

  final AdminUser user;
  final ValueChanged<String> onChangeRole;
  final VoidCallback onToggleActive;
  final VoidCallback onDetail;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
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
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetail,
                    child: Text(s.userDetailTitle),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onResetPassword,
                    child: Text(s.resetPasswordAction),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(s.assignRole, style: AppTextStyles.overline),
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
                    label: Text(roleLabel(s, r)),
                    selected: user.role == r,
                    onSelected: user.role == r ? null : (_) => onChangeRole(r),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onToggleActive,
                icon: Icon(user.active ? Icons.block_rounded : AppIcons.check),
                label: Text(user.active ? s.blockUser : s.activateUser),
                style: OutlinedButton.styleFrom(
                  foregroundColor: user.active
                      ? AppColors.dangerText
                      : AppColors.successText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

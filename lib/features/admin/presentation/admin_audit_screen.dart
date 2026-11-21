import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';

/// Who did what: every sensitive admin action, newest first.
class AdminAuditScreen extends ConsumerStatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  ConsumerState<AdminAuditScreen> createState() => _AuditState();
}

class _AuditState extends ConsumerState<AdminAuditScreen> {
  final List<AuditEntry> _items = <AuditEntry>[];
  int _page = 0;
  int _totalPages = 1;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final AdminPage<AuditEntry> p =
          await ref.read(adminRepositoryProvider).audit(page: _page);
      if (!mounted) return;
      setState(() {
        _items.addAll(p.content);
        _totalPages = p.totalPages;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final DateFormat fmt = DateFormat('dd.MM.yyyy HH:mm');
    Widget body;
    if (_loading && _items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null && _items.isEmpty) {
      body = EmptyState(title: s.notLoaded, subtitle: _error);
    } else if (_items.isEmpty) {
      body = EmptyState(title: s.auditEmpty, icon: Icons.history_rounded);
    } else {
      final bool more = _page + 1 < _totalPages;
      body = ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: _items.length + (more ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, int i) {
          if (i >= _items.length) {
            return Center(
              child: OutlinedButton(
                onPressed: _loading
                    ? null
                    : () {
                        _page++;
                        _load();
                      },
                child: Text(s.loadMore),
              ),
            );
          }
          final AuditEntry e = _items[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(e.action,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700)),
              Text('${e.actorEmail ?? '—'} → ${e.targetType ?? ''}',
                  style: AppTextStyles.bodySm),
              if ((e.detail ?? '').isNotEmpty)
                Text(e.detail!, style: AppTextStyles.bodySm),
              if (e.createdAt != null)
                Text(fmt.format(e.createdAt!), style: AppTextStyles.caption),
            ],
          );
        },
      );
    }
    return Scaffold(appBar: AppBar(title: Text(s.auditTitle)), body: body);
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../application/companies_providers.dart';
import '../domain/company.dart';
import 'widgets/category_chips.dart';
import 'widgets/company_card.dart';

/// "Kompaniyalar" — a focused directory of every business, with search
/// and category filtering. Distinct from the home feed (which mixes in
/// stories, promotions and featured picks). Sits on the 2nd nav tab in
/// place of the old "Hədiyyə" tab.
class CompaniesScreen extends ConsumerWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<Company>> companies = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.tabCompanies)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(companiesProvider),
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: _CompanySearchField(),
            ),
            const CategoryChips(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: companies.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                // Scrollable so pull-to-refresh works on these states too.
                error: (Object e, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: <Widget>[
                    ErrorState(error: e, onRetry: () => ref.invalidate(companiesProvider)),
                  ],
                ),
                data: (List<Company> list) {
                  if (list.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: <Widget>[
                        EmptyState(
                          title: s.nothingFound,
                          subtitle: s.nothingFoundHint,
                          icon: AppIcons.searchOff,
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.huge,
                    ),
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (BuildContext _, int i) => CompanyCard(
                      company: list[i],
                      onTap: () => context.push('/companies/${list[i].id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanySearchField extends ConsumerStatefulWidget {
  const _CompanySearchField();

  @override
  ConsumerState<_CompanySearchField> createState() =>
      _CompanySearchFieldState();
}

class _CompanySearchFieldState extends ConsumerState<_CompanySearchField> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final String q = value.trim();
      if (q != ref.read(searchQueryProvider)) {
        ref.read(searchQueryProvider.notifier).state = q;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: ref.watch(sProvider).search,
        prefixIcon: const Icon(AppIcons.search, size: 22),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (BuildContext _, TextEditingValue v, __) {
            if (v.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(AppIcons.close, size: 18),
              onPressed: () {
                _controller.clear();
                _debounce?.cancel();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            );
          },
        ),
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

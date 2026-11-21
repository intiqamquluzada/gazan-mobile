import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/panel_repository.dart';
import '../domain/panel_models.dart';

final Provider<PanelRepository> panelRepositoryProvider =
    Provider<PanelRepository>(
  (Ref ref) => PanelRepository(ref.read(apiClientProvider)),
);

final AutoDisposeFutureProviderFamily<BusinessAnalytics, int>
    businessAnalyticsProvider =
    FutureProvider.autoDispose.family<BusinessAnalytics, int>(
  (Ref ref, int days) => ref.read(panelRepositoryProvider).analytics(days),
);

final AutoDisposeFutureProvider<List<StaffMember>> staffProvider =
    FutureProvider.autoDispose<List<StaffMember>>(
  (Ref ref) => ref.read(panelRepositoryProvider).staff(),
);

final AutoDisposeFutureProvider<List<SubmittedNotification>>
    mySubmissionsProvider =
    FutureProvider.autoDispose<List<SubmittedNotification>>(
  (Ref ref) => ref.read(panelRepositoryProvider).mySubmissions(),
);

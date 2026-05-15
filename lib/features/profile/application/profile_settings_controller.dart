import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User-tweakable notification preferences (mock — in-memory only).
class NotificationPrefs {
  const NotificationPrefs({
    this.newRewards = true,
    this.nearbyOffers = true,
    this.weeklyRecap = false,
    this.marketing = false,
  });

  final bool newRewards;
  final bool nearbyOffers;
  final bool weeklyRecap;
  final bool marketing;

  NotificationPrefs copyWith({
    bool? newRewards,
    bool? nearbyOffers,
    bool? weeklyRecap,
    bool? marketing,
  }) =>
      NotificationPrefs(
        newRewards: newRewards ?? this.newRewards,
        nearbyOffers: nearbyOffers ?? this.nearbyOffers,
        weeklyRecap: weeklyRecap ?? this.weeklyRecap,
        marketing: marketing ?? this.marketing,
      );
}

class NotificationPrefsController extends StateNotifier<NotificationPrefs> {
  NotificationPrefsController() : super(const NotificationPrefs());

  void toggleNewRewards(bool v) =>
      state = state.copyWith(newRewards: v);
  void toggleNearbyOffers(bool v) =>
      state = state.copyWith(nearbyOffers: v);
  void toggleWeeklyRecap(bool v) =>
      state = state.copyWith(weeklyRecap: v);
  void toggleMarketing(bool v) =>
      state = state.copyWith(marketing: v);
}

final StateNotifierProvider<NotificationPrefsController, NotificationPrefs>
    notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsController, NotificationPrefs>(
  (Ref ref) => NotificationPrefsController(),
);

/// Selected interface language code: 'az', 'en', 'ru'.
final StateProvider<String> languageProvider =
    StateProvider<String>((Ref ref) => 'az');

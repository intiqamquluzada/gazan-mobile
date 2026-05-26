import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-tweakable notification preferences, persisted via
/// [SharedPreferences] so they survive app restarts.
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
  NotificationPrefsController() : super(const NotificationPrefs()) {
    _restore();
  }

  static const String _kNew = 'qazan.notif.newRewards';
  static const String _kNearby = 'qazan.notif.nearbyOffers';
  static const String _kWeekly = 'qazan.notif.weeklyRecap';
  static const String _kMarketing = 'qazan.notif.marketing';

  Future<void> _restore() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    state = NotificationPrefs(
      newRewards: p.getBool(_kNew) ?? true,
      nearbyOffers: p.getBool(_kNearby) ?? true,
      weeklyRecap: p.getBool(_kWeekly) ?? false,
      marketing: p.getBool(_kMarketing) ?? false,
    );
  }

  Future<void> _persist() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setBool(_kNew, state.newRewards);
    await p.setBool(_kNearby, state.nearbyOffers);
    await p.setBool(_kWeekly, state.weeklyRecap);
    await p.setBool(_kMarketing, state.marketing);
  }

  void toggleNewRewards(bool v) {
    state = state.copyWith(newRewards: v);
    _persist();
  }

  void toggleNearbyOffers(bool v) {
    state = state.copyWith(nearbyOffers: v);
    _persist();
  }

  void toggleWeeklyRecap(bool v) {
    state = state.copyWith(weeklyRecap: v);
    _persist();
  }

  void toggleMarketing(bool v) {
    state = state.copyWith(marketing: v);
    _persist();
  }
}

final StateNotifierProvider<NotificationPrefsController, NotificationPrefs>
    notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsController, NotificationPrefs>(
  (Ref ref) => NotificationPrefsController(),
);

/// All UI languages the app supports. The order here drives the
/// language picker sheet, and adding a new entry is the only place
/// you need to touch when introducing another locale.
const List<String> kSupportedLanguages = <String>['az', 'en', 'ru', 'tr'];

/// Holds the current UI language code and persists every change.
class LanguageController extends StateNotifier<String> {
  LanguageController() : super('az') {
    _restore();
  }

  static const String _kKey = 'qazan.lang';

  Future<void> _restore() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    final String? saved = p.getString(_kKey);
    if (saved != null && kSupportedLanguages.contains(saved)) {
      state = saved;
    }
  }

  /// Switches the current language and writes it to disk so it
  /// survives app restarts.
  Future<void> setLanguage(String code) async {
    if (!kSupportedLanguages.contains(code) || code == state) return;
    state = code;
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setString(_kKey, code);
  }
}

/// Selected interface language code: 'az', 'en', 'ru', 'tr'.
final StateNotifierProvider<LanguageController, String> languageProvider =
    StateNotifierProvider<LanguageController, String>(
  (Ref ref) => LanguageController(),
);

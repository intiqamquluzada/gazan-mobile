import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/domain/app_user.dart';
import '../data/profile_remote_data_source.dart';

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

  Map<String, bool> toJson() => <String, bool>{
        'rewards': newRewards,
        'offers': nearbyOffers,
        'weekly': weeklyRecap,
        'marketing': marketing,
      };

  static NotificationPrefs fromJson(Map<String, bool> j) => NotificationPrefs(
        newRewards: j['rewards'] ?? true,
        nearbyOffers: j['offers'] ?? true,
        weeklyRecap: j['weekly'] ?? false,
        marketing: j['marketing'] ?? false,
      );
}

/// The switches live on the server, which is what decides whether a push
/// is sent; a copy is kept on the phone so the screen opens instantly.
class NotificationPrefsController extends StateNotifier<NotificationPrefs> {
  NotificationPrefsController(this._ref) : super(const NotificationPrefs()) {
    _ready = _restore();
    _ref.listen<AppUser?>(
        currentUserProvider, (AppUser? _, AppUser? user) => _onUser(user),
        fireImmediately: true);
  }

  final Ref _ref;
  late final Future<void> _ready;
  String? _syncedFor;

  /// Set once this phone's switches were sent for an account, so later
  /// sign-ins adopt the server's values instead of overwriting them.
  static String _kSynced(String userId) => 'qazan.notif.synced.$userId';

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

  Future<void> _onUser(AppUser? user) async {
    if (user == null) {
      _syncedFor = null;
      return;
    }
    final Map<String, bool>? server = user.notificationPrefs;
    if (server == null || _syncedFor == user.id) return;
    _syncedFor = user.id;
    await _ready;
    final SharedPreferences p = await SharedPreferences.getInstance();
    if (p.getBool(_kSynced(user.id)) ?? false) {
      state = NotificationPrefs.fromJson(server);
      await _persist();
      return;
    }
    // First run against a server that stores the switches: the choices
    // made on this phone before win (until now they never reached it).
    final bool changedHere = p.containsKey(_kNew) ||
        p.containsKey(_kNearby) ||
        p.containsKey(_kWeekly) ||
        p.containsKey(_kMarketing);
    if (!changedHere) {
      state = NotificationPrefs.fromJson(server);
      await _persist();
      await p.setBool(_kSynced(user.id), true);
      return;
    }
    if (await _upload()) await p.setBool(_kSynced(user.id), true);
  }

  /// Sends the switches to the server. False when it could not be reached.
  Future<bool> _upload() async {
    if (_ref.read(currentUserProvider) == null) return false;
    try {
      await _ref
          .read(profileRemoteDataSourceProvider)
          .updateNotificationPrefs(state.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _changed(NotificationPrefs next) async {
    final NotificationPrefs before = state;
    state = next;
    await _persist();
    if (_ref.read(currentUserProvider) == null) return;
    if (!await _upload() && mounted) {
      // The server still has the old value, so the switch would lie.
      state = before;
      await _persist();
    }
  }

  Future<void> _persist() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setBool(_kNew, state.newRewards);
    await p.setBool(_kNearby, state.nearbyOffers);
    await p.setBool(_kWeekly, state.weeklyRecap);
    await p.setBool(_kMarketing, state.marketing);
  }

  void toggleNewRewards(bool v) => _changed(state.copyWith(newRewards: v));

  void toggleNearbyOffers(bool v) => _changed(state.copyWith(nearbyOffers: v));

  void toggleWeeklyRecap(bool v) => _changed(state.copyWith(weeklyRecap: v));

  void toggleMarketing(bool v) => _changed(state.copyWith(marketing: v));
}

final StateNotifierProvider<NotificationPrefsController, NotificationPrefs>
    notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsController, NotificationPrefs>(
  (Ref ref) => NotificationPrefsController(ref),
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
      return;
    }
    // First launch: follow the phone. The app serves Azerbaijan and Türkiye,
    // so a Turkish phone should not start in Azerbaijani.
    final String device =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (kSupportedLanguages.contains(device)) {
      state = device;
    } else {
      state = 'en';
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

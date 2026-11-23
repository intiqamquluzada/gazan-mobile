import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazan/core/network/api_client.dart';
import 'package:qazan/features/auth/application/auth_controller.dart';
import 'package:qazan/features/auth/domain/app_user.dart';
import 'package:qazan/features/auth/domain/user_role.dart';
import 'package:qazan/features/profile/application/profile_settings_controller.dart';
import 'package:qazan/features/profile/data/profile_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRemote extends ProfileRemoteDataSource {
  _FakeRemote({required this.fail}) : super(ApiClient(Dio()));
  bool fail;
  final List<Map<String, bool>> sent = <Map<String, bool>>[];

  @override
  Future<AppUser> updateNotificationPrefs(Map<String, bool> prefs) async {
    if (fail) throw Exception('server unreachable');
    sent.add(prefs);
    return _user;
  }
}

const AppUser _user = AppUser(
  id: 'u1',
  fullName: 'Test',
  email: 't@test.az',
  role: UserRole.customer,
  notificationPrefs: <String, bool>{
    'rewards': true, 'offers': true, 'weekly': false, 'marketing': false,
  },
);

ProviderContainer _container(_FakeRemote remote) => ProviderContainer(
      overrides: <Override>[
        currentUserProvider.overrideWithValue(_user),
        profileRemoteDataSourceProvider.overrideWithValue(remote),
      ],
    );

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('a switch stays where the user put it when the server fails', () async {
    final _FakeRemote remote = _FakeRemote(fail: true);
    final ProviderContainer c = _container(remote);
    addTearDown(c.dispose);
    c.read(notificationPrefsProvider);
    await _settle();

    c.read(notificationPrefsProvider.notifier).toggleNewRewards(false);
    await _settle();

    expect(c.read(notificationPrefsProvider).newRewards, isFalse);
    final SharedPreferences p = await SharedPreferences.getInstance();
    expect(p.getBool('qazan.notif.pending'), isTrue);
  });

  test('a change reaches the server', () async {
    final _FakeRemote remote = _FakeRemote(fail: false);
    final ProviderContainer c = _container(remote);
    addTearDown(c.dispose);
    c.read(notificationPrefsProvider);
    await _settle();

    c.read(notificationPrefsProvider.notifier).toggleMarketing(true);
    await _settle();

    expect(c.read(notificationPrefsProvider).marketing, isTrue);
    expect(remote.sent.last['marketing'], isTrue);
    final SharedPreferences p = await SharedPreferences.getInstance();
    expect(p.getBool('qazan.notif.pending'), isFalse);
  });
}

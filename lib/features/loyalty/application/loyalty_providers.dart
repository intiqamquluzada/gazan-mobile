import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../data/loyalty_repository.dart';
import '../domain/loyalty_card.dart';
import '../domain/loyalty_program.dart';

final Provider<LoyaltyRepository> loyaltyRepositoryProvider =
    Provider<LoyaltyRepository>(
  (Ref ref) => RemoteLoyaltyRepository(ref.read(apiClientProvider)),
);

final FutureProviderFamily<List<LoyaltyProgram>, String>
    programsForCompanyProvider =
    FutureProvider.family<List<LoyaltyProgram>, String>(
  (Ref ref, String companyId) =>
      ref.read(loyaltyRepositoryProvider).programsForCompany(companyId),
);

final FutureProviderFamily<LoyaltyProgram?, String> programByIdProvider =
    FutureProvider.family<LoyaltyProgram?, String>(
  (Ref ref, String programId) =>
      ref.read(loyaltyRepositoryProvider).programById(programId),
);

/// Active loyalty cards for the signed-in user.
final FutureProvider<List<LoyaltyCard>> myCardsProvider =
    FutureProvider<List<LoyaltyCard>>((Ref ref) async {
  final String? userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return <LoyaltyCard>[];
  return ref.read(loyaltyRepositoryProvider).cardsForUser(userId);
});

/// Imperative actions used from the UI to mutate loyalty state.
class LoyaltyActions {
  LoyaltyActions(this._ref);

  final Ref _ref;

  // ── Customer side ──

  Future<LoyaltyCard> joinProgram(String programId) async {
    final String? userId = _ref.read(currentUserProvider)?.id;
    if (userId == null) {
      throw StateError('Sign in to join a loyalty program.');
    }
    final LoyaltyCard card = await _ref
        .read(loyaltyRepositoryProvider)
        .joinProgram(userId: userId, programId: programId);
    _ref.invalidate(myCardsProvider);
    return card;
  }

  /// Business action — backend route is `POST /scans`. Used by the
  /// QR scanner screen on the business side after a customer's QR is
  /// recognized.
  Future<LoyaltyCard> scanCustomer({
    required String customerId,
    required String programId,
    int amount = 1,
    String? note,
  }) async {
    final LoyaltyCard updated =
        await _ref.read(loyaltyRepositoryProvider).scan(
              customerId: customerId,
              programId: programId,
              stamps: amount,
              note: note,
            );
    _ref.invalidate(myCardsProvider);
    return updated;
  }

  Future<LoyaltyCard> redeem(String cardId) async {
    final LoyaltyCard updated =
        await _ref.read(loyaltyRepositoryProvider).redeemReward(cardId);
    _ref.invalidate(myCardsProvider);
    return updated;
  }

  // ── Business side ──

  Future<LoyaltyProgram> createProgram({
    required String companyId,
    required String title,
    required String description,
    required int stampsRequired,
    required LoyaltyRewardType rewardType,
    num? rewardValue,
    String rewardItem = 'məhsul',
  }) async {
    final LoyaltyProgram program =
        await _ref.read(loyaltyRepositoryProvider).createProgram(
              companyId: companyId,
              title: title,
              description: description,
              stampsRequired: stampsRequired,
              rewardType: rewardType,
              rewardValue: rewardValue,
              rewardItem: rewardItem,
            );
    _ref.invalidate(programsForCompanyProvider(companyId));
    return program;
  }

  Future<LoyaltyProgram> toggleActive(LoyaltyProgram program) async {
    final LoyaltyProgram updated = await _ref
        .read(loyaltyRepositoryProvider)
        .updateProgram(program.copyWith(isActive: !program.isActive));
    _ref.invalidate(programsForCompanyProvider(program.companyId));
    return updated;
  }

  Future<void> deleteProgram(LoyaltyProgram program) async {
    await _ref
        .read(loyaltyRepositoryProvider)
        .deleteProgram(program.id);
    _ref.invalidate(programsForCompanyProvider(program.companyId));
  }
}

final Provider<LoyaltyActions> loyaltyActionsProvider =
    Provider<LoyaltyActions>((Ref ref) => LoyaltyActions(ref));

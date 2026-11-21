import 'package:flutter_test/flutter_test.dart';
import 'package:qazan/features/business/domain/customer_summary.dart';
import 'package:qazan/features/loyalty/domain/loyalty_card.dart';
import 'package:qazan/features/loyalty/domain/loyalty_program.dart';
import 'package:qazan/features/nfc/data/nfc_repository.dart';

void main() {
  const LoyaltyProgram program = LoyaltyProgram(
    id: 'p1',
    companyId: 'c1',
    title: '5 qəhvəyə 1 hədiyyə',
    description: '',
    stampsRequired: 8, // the owner raised it from 5
    rewardType: LoyaltyRewardType.freeItem,
  );

  group('stamp progress', () {
    test('uses the card\'s own target when the customer has a card', () {
      final LoyaltyCard card = LoyaltyCard(
        id: 'k1',
        userId: 'u1',
        companyId: 'c1',
        programId: 'p1',
        stamps: 3,
        stampsRequired: 5, // the card was started under the old rule
        rewardsAvailable: 0,
        lastActivityAt: DateTime(2026),
      );
      expect(program.stampsToFill(card), 5);
    });

    test('falls back to the program when there is no card yet', () {
      expect(program.stampsToFill(null), 8);
    });
  });

  group('open programs', () {
    test('a paused or expired program is not open', () {
      expect(program.isOpen, isTrue);
      expect(program.copyWith(isActive: false).isOpen, isFalse);
      expect(
          program
              .copyWith(expiresAt: DateTime.now().subtract(const Duration(days: 1)))
              .isOpen,
          isFalse);
    });
  });

  group('tap result parsing', () {
    test('reads the unlocked gift and the venue balance', () {
      final NfcTapResult r = NfcTapResult.fromJson(<String, dynamic>{
        'kind': 'STAMP',
        'companyName': 'Kafe',
        'stampsAdded': 1,
        'stampsNow': 0,
        'stampsRequired': 5,
        'pointsBalance': 120,
        'rewardUnlocked': true,
        'unlockedRewardTitle': 'Pulsuz qəhvə',
      });
      expect(r.rewardUnlocked, isTrue);
      expect(r.unlockedRewardTitle, 'Pulsuz qəhvə');
      expect(r.pointsBalance, 120);
    });

    test('an older server without the new fields still parses', () {
      final NfcTapResult r = NfcTapResult.fromJson(<String, dynamic>{
        'kind': 'POINTS',
        'companyName': 'Kafe',
        'pointsAdded': 100,
      });
      expect(r.unlockedRewardTitle, isNull);
      expect(r.pointsBalance, 0);
    });

    test('an expired cashier window is recognised', () {
      final SpendStatus st = SpendStatus.fromJson(<String, dynamic>{
        'id': 's1',
        'status': 'EXPIRED',
        'companyName': 'Kafe',
      });
      expect(st.isOpen, isFalse);
      expect(st.isExpired, isTrue);
    });
  });

  test('customer summary reads the coin balance, default 0', () {
    expect(
        CustomerSummary.fromJson(<String, dynamic>{'coinBalance': 40})
            .coinBalance,
        40);
    expect(CustomerSummary.fromJson(<String, dynamic>{}).coinBalance, 0);
  });
}

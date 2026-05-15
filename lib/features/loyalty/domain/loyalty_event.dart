/// One event in the loyalty history — either a stamp added or a reward claimed.
enum LoyaltyEventType { stampAdded, rewardClaimed }

class LoyaltyEvent {
  const LoyaltyEvent({
    required this.id,
    required this.cardId,
    required this.companyId,
    required this.type,
    required this.amount,
    required this.timestamp,
    this.note,
  });

  final String id;
  final String cardId;
  final String companyId;
  final LoyaltyEventType type;

  /// Stamp count for [LoyaltyEventType.stampAdded], rewards for
  /// [LoyaltyEventType.rewardClaimed].
  final int amount;

  final DateTime timestamp;
  final String? note;
}

// Value types for the business panel's cashier window, staff and analytics,
// parsed straight from the backend JSON.

int _int(Object? v) => ((v as num?) ?? 0).toInt();

DateTime? _date(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;

List<Map<String, dynamic>> _maps(Object? v) =>
    ((v as List<dynamic>?) ?? const <dynamic>[]).cast<Map<String, dynamic>>();

class SpendCard {
  const SpendCard({
    required this.programTitle,
    required this.stamps,
    required this.stampsRequired,
    required this.rewardsAvailable,
  });

  final String programTitle;
  final int stamps;
  final int stampsRequired;
  final int rewardsAvailable;

  factory SpendCard.fromJson(Map<String, dynamic> j) => SpendCard(
        programTitle: (j['programTitle'] as String?) ?? '',
        stamps: _int(j['stamps']),
        stampsRequired: _int(j['stampsRequired']),
        rewardsAvailable: _int(j['rewardsAvailable']),
      );
}

class SpendReward {
  const SpendReward({
    required this.kind,
    required this.id,
    required this.title,
    required this.coinCost,
  });

  final String kind; // COIN | CARD
  final String id;
  final String title;
  final int coinCost;

  factory SpendReward.fromJson(Map<String, dynamic> j) => SpendReward(
        kind: (j['kind'] as String?) ?? 'COIN',
        id: j['id'] as String,
        title: (j['title'] as String?) ?? '',
        coinCost: _int(j['coinCost']),
      );
}

/// One customer standing at the till after tapping the "spend" card.
class SpendSession {
  const SpendSession({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.coinBalance,
    required this.cards,
    required this.rewards,
    this.customerPhone,
    this.avatarUrl,
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? avatarUrl;
  final int coinBalance;
  final List<SpendCard> cards;
  final List<SpendReward> rewards;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  factory SpendSession.fromJson(Map<String, dynamic> j) => SpendSession(
        id: j['id'] as String,
        customerId: (j['customerId'] as String?) ?? '',
        customerName: (j['customerName'] as String?) ?? '—',
        customerPhone: j['customerPhone'] as String?,
        avatarUrl: j['avatarUrl'] as String?,
        coinBalance: _int(j['coinBalance']),
        cards: _maps(j['cards']).map(SpendCard.fromJson).toList(),
        rewards: _maps(j['rewards']).map(SpendReward.fromJson).toList(),
        createdAt: _date(j['createdAt']),
        expiresAt: _date(j['expiresAt']),
      );
}

class StaffMember {
  const StaffMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.active,
    this.phone,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final bool active;
  final DateTime? createdAt;

  factory StaffMember.fromJson(Map<String, dynamic> j) => StaffMember(
        id: j['id'] as String,
        fullName: (j['fullName'] as String?) ?? '',
        email: (j['email'] as String?) ?? '',
        phone: j['phone'] as String?,
        active: (j['active'] as bool?) ?? true,
        createdAt: _date(j['createdAt']),
      );
}

class CustomerLookup {
  const CustomerLookup({
    required this.userId,
    required this.fullName,
    this.phone,
  });

  final String userId;
  final String fullName;
  final String? phone;

  factory CustomerLookup.fromJson(Map<String, dynamic> j) => CustomerLookup(
        userId: j['userId'] as String,
        fullName: (j['fullName'] as String?) ?? '',
        phone: j['phone'] as String?,
      );
}

class DailyPoint {
  const DailyPoint({
    required this.date,
    required this.stamps,
    required this.rewards,
    required this.coinsEarned,
  });

  final String date;
  final int stamps;
  final int rewards;
  final int coinsEarned;

  factory DailyPoint.fromJson(Map<String, dynamic> j) => DailyPoint(
        date: '${j['date'] ?? ''}',
        stamps: _int(j['stamps']),
        rewards: _int(j['rewards']),
        coinsEarned: _int(j['coinsEarned']),
      );
}

class ProgramPerformance {
  const ProgramPerformance({
    required this.programId,
    required this.title,
    required this.active,
    required this.members,
    required this.completed,
    required this.redeemed,
  });

  final String programId;
  final String title;
  final bool active;
  final int members;
  final int completed;
  final int redeemed;

  factory ProgramPerformance.fromJson(Map<String, dynamic> j) =>
      ProgramPerformance(
        programId: '${j['programId'] ?? ''}',
        title: (j['title'] as String?) ?? '',
        active: (j['active'] as bool?) ?? true,
        members: _int(j['members']),
        completed: _int(j['completed']),
        redeemed: _int(j['redeemed']),
      );
}

class BusinessAnalytics {
  const BusinessAnalytics({
    required this.newCustomers,
    required this.activeCustomers,
    required this.returningCustomers,
    required this.stamps,
    required this.rewardsClaimed,
    required this.coinsEarned,
    required this.coinsSpent,
    required this.nfcAccepted,
    required this.nfcRejected,
    required this.daily,
    required this.programs,
  });

  final int newCustomers;
  final int activeCustomers;
  final int returningCustomers;
  final int stamps;
  final int rewardsClaimed;
  final int coinsEarned;
  final int coinsSpent;
  final int nfcAccepted;
  final int nfcRejected;
  final List<DailyPoint> daily;
  final List<ProgramPerformance> programs;

  factory BusinessAnalytics.fromJson(Map<String, dynamic> j) =>
      BusinessAnalytics(
        newCustomers: _int(j['newCustomers']),
        activeCustomers: _int(j['activeCustomers']),
        returningCustomers: _int(j['returningCustomers']),
        stamps: _int(j['stamps']),
        rewardsClaimed: _int(j['rewardsClaimed']),
        coinsEarned: _int(j['coinsEarned']),
        coinsSpent: _int(j['coinsSpent']),
        nfcAccepted: _int(j['nfcAccepted']),
        nfcRejected: _int(j['nfcRejected']),
        daily: _maps(j['daily']).map(DailyPoint.fromJson).toList(),
        programs:
            _maps(j['programs']).map(ProgramPerformance.fromJson).toList(),
      );
}

/// A notification the owner sent for review, or one an admin is reviewing.
class SubmittedNotification {
  const SubmittedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String status; // PENDING | APPROVED | REJECTED | SENT
  final DateTime? createdAt;

  factory SubmittedNotification.fromJson(Map<String, dynamic> j) =>
      SubmittedNotification(
        id: j['id'] as String,
        title: (j['title'] as String?) ?? '',
        body: (j['body'] as String?) ?? '',
        status: (j['status'] as String?) ?? 'PENDING',
        createdAt: _date(j['createdAt']),
      );
}

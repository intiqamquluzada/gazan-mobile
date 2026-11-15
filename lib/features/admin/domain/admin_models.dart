// Domain models for the admin panel. Plain immutable value types parsed
// straight from the backend's `/api/v1/admin/*` JSON.

class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.customers,
    required this.businessOwners,
    required this.admins,
    required this.totalCompanies,
    required this.featuredCompanies,
    required this.totalLoyaltyCards,
    required this.coinsCirculating,
    required this.coinsEarned,
    required this.coinsSpent,
    required this.coinTransactions,
    required this.recentUsers,
    required this.recentCompanies,
    this.newUsers7d = 0,
    this.newCompanies7d = 0,
    this.pendingCompanies = 0,
    this.pendingNotifications = 0,
    this.activeUsers30d = 0,
    this.signups = const <SignupPoint>[],
  });

  final int newUsers7d;
  final int newCompanies7d;
  final int pendingCompanies;
  final int pendingNotifications;
  final int activeUsers30d;
  final List<SignupPoint> signups;

  final int totalUsers;
  final int customers;
  final int businessOwners;
  final int admins;
  final int totalCompanies;
  final int featuredCompanies;
  final int totalLoyaltyCards;
  final int coinsCirculating;
  final int coinsEarned;
  final int coinsSpent;
  final int coinTransactions;
  final List<AdminUser> recentUsers;
  final List<AdminCompany> recentCompanies;

  static int _i(Object? v) => ((v as num?) ?? 0).toInt();

  factory AdminStats.fromJson(Map<String, dynamic> j) {
    return AdminStats(
      totalUsers: _i(j['totalUsers']),
      customers: _i(j['customers']),
      businessOwners: _i(j['businessOwners']),
      admins: _i(j['admins']),
      totalCompanies: _i(j['totalCompanies']),
      featuredCompanies: _i(j['featuredCompanies']),
      totalLoyaltyCards: _i(j['totalLoyaltyCards']),
      coinsCirculating: _i(j['coinsCirculating']),
      coinsEarned: _i(j['coinsEarned']),
      coinsSpent: _i(j['coinsSpent']),
      coinTransactions: _i(j['coinTransactions']),
      newUsers7d: _i(j['newUsers7d']),
      newCompanies7d: _i(j['newCompanies7d']),
      pendingCompanies: _i(j['pendingCompanies']),
      pendingNotifications: _i(j['pendingNotifications']),
      activeUsers30d: _i(j['activeUsers30d']),
      signups: ((j['signups'] as List<dynamic>?) ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(SignupPoint.fromJson)
          .toList(growable: false),
      recentUsers: ((j['recentUsers'] as List<dynamic>?) ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(AdminUser.fromJson)
          .toList(growable: false),
      recentCompanies: ((j['recentCompanies'] as List<dynamic>?) ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(AdminCompany.fromJson)
          .toList(growable: false),
    );
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.active,
    this.phone,
    this.lastLoginAt,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role; // CUSTOMER | BUSINESS_OWNER | ADMIN
  final bool active;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  factory AdminUser.fromJson(Map<String, dynamic> j) {
    return AdminUser(
      id: j['id'] as String,
      fullName: (j['fullName'] as String?) ?? '',
      email: (j['email'] as String?) ?? '',
      phone: j['phone'] as String?,
      role: (j['role'] as String?) ?? 'CUSTOMER',
      active: (j['active'] as bool?) ?? true,
      lastLoginAt: _date(j['lastLoginAt']),
      createdAt: _date(j['createdAt']),
    );
  }
}

class AdminCompany {
  const AdminCompany({
    required this.id,
    required this.name,
    required this.category,
    required this.featured,
    this.tagline,
    this.rating,
    this.reviewCount = 0,
    this.ownerName,
    this.ownerEmail,
    this.createdAt,
    this.status = 'APPROVED',
  });

  /// PENDING | APPROVED | SUSPENDED
  final String status;

  final String id;
  final String name;
  final String? tagline;
  final String category;
  final bool featured;
  final double? rating;
  final int reviewCount;
  final String? ownerName;
  final String? ownerEmail;
  final DateTime? createdAt;

  factory AdminCompany.fromJson(Map<String, dynamic> j) {
    return AdminCompany(
      id: j['id'] as String,
      name: (j['name'] as String?) ?? '',
      tagline: j['tagline'] as String?,
      category: (j['category'] as String?) ?? '',
      featured: (j['featured'] as bool?) ?? false,
      rating: (j['rating'] as num?)?.toDouble(),
      reviewCount: ((j['reviewCount'] as num?) ?? 0).toInt(),
      ownerName: j['ownerName'] as String?,
      ownerEmail: j['ownerEmail'] as String?,
      createdAt: _date(j['createdAt']),
      status: (j['status'] as String?) ?? 'APPROVED',
    );
  }
}

class SignupPoint {
  const SignupPoint({required this.date, required this.count});

  final String date;
  final int count;

  factory SignupPoint.fromJson(Map<String, dynamic> j) => SignupPoint(
        date: '${j['date'] ?? ''}',
        count: ((j['count'] as num?) ?? 0).toInt(),
      );
}

/// A venue with the numbers an admin needs to review it.
class AdminCompanyDetail {
  const AdminCompanyDetail({
    required this.id,
    required this.name,
    required this.status,
    required this.customers,
    required this.tags,
    required this.coinsEarned,
    required this.coinsSpent,
    this.ownerEmail,
    this.address,
    this.tagline,
    this.category,
    this.phone,
    this.ownerName,
    this.createdAt,
  });

  final String id;
  final String name;
  final String status;
  final String? tagline;
  final String? category;
  final String? phone;
  final String? ownerName;
  final DateTime? createdAt;
  final int customers;
  final int tags;
  final int coinsEarned;
  final int coinsSpent;
  final String? ownerEmail;
  final String? address;

  factory AdminCompanyDetail.fromJson(Map<String, dynamic> j) {
    int count(String k) {
      final Object? v = j[k];
      if (v is List) return v.length;
      return ((v as num?) ?? 0).toInt();
    }

    return AdminCompanyDetail(
      id: j['id'] as String,
      name: (j['name'] as String?) ?? '',
      status: (j['status'] as String?) ?? 'APPROVED',
      customers: count('customers'),
      tags: count('tags'),
      coinsEarned: count('coinsEarned'),
      coinsSpent: count('coinsSpent'),
      ownerEmail: j['ownerEmail'] as String?,
      address: j['address'] as String?,
      tagline: j['tagline'] as String?,
      category: j['category'] as String?,
      phone: j['phone'] as String?,
      ownerName: j['ownerName'] as String?,
      createdAt: _date(j['createdAt']),
    );
  }
}

class AdminCoinLine {
  const AdminCoinLine({
    required this.amount,
    this.companyName,
    this.note,
    this.createdAt,
  });

  final int amount;
  final String? companyName;
  final String? note;
  final DateTime? createdAt;

  factory AdminCoinLine.fromJson(Map<String, dynamic> j) => AdminCoinLine(
        amount: ((j['amount'] as num?) ?? 0).toInt(),
        companyName: j['companyName'] as String?,
        note: j['note'] as String?,
        createdAt: _date(j['createdAt']),
      );
}

class AdminUserDetail {
  const AdminUserDetail({
    required this.user,
    required this.cardCount,
    required this.coinBalance,
    required this.recentCoins,
  });

  final AdminUser user;
  final int cardCount;
  final int coinBalance;
  final List<AdminCoinLine> recentCoins;

  factory AdminUserDetail.fromJson(Map<String, dynamic> j) {
    final Object? cards = j['cards'];
    return AdminUserDetail(
      user: AdminUser.fromJson(j),
      cardCount:
          cards is List ? cards.length : ((cards as num?) ?? 0).toInt(),
      coinBalance: ((j['coinBalance'] as num?) ?? 0).toInt(),
      recentCoins: ((j['recentCoins'] as List<dynamic>?) ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(AdminCoinLine.fromJson)
          .toList(growable: false),
    );
  }
}

class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.action,
    this.actorEmail,
    this.targetType,
    this.targetId,
    this.detail,
    this.createdAt,
  });

  final String id;
  final String action;
  final String? actorEmail;
  final String? targetType;
  final String? targetId;
  final String? detail;
  final DateTime? createdAt;

  factory AuditEntry.fromJson(Map<String, dynamic> j) => AuditEntry(
        id: '${j['id']}',
        action: (j['action'] as String?) ?? '',
        actorEmail: j['actorEmail'] as String?,
        targetType: j['targetType'] as String?,
        targetId: j['targetId'] as String?,
        detail: j['detail'] as String?,
        createdAt: _date(j['createdAt']),
      );
}

class CompanyCoinRow {
  const CompanyCoinRow({
    required this.companyId,
    required this.name,
    required this.earned,
    required this.spent,
    required this.grants,
  });

  final String companyId;
  final String name;
  final int earned;
  final int spent;
  final int grants;

  factory CompanyCoinRow.fromJson(Map<String, dynamic> j) {
    int g(String k) => ((j[k] as num?) ?? 0).toInt();
    return CompanyCoinRow(
      companyId: '${j['companyId'] ?? ''}',
      name: (j['name'] as String?) ?? '',
      earned: g('earned'),
      spent: g('spent'),
      grants: g('grants'),
    );
  }
}

class AdminCoinTxn {
  const AdminCoinTxn({
    required this.id,
    required this.amount,
    required this.type,
    this.userName,
    this.userEmail,
    this.companyName,
    this.note,
    this.createdAt,
  });

  final String id;
  final int amount;
  final String type; // EARN | SPEND
  final String? userName;
  final String? userEmail;
  final String? companyName;
  final String? note;
  final DateTime? createdAt;

  factory AdminCoinTxn.fromJson(Map<String, dynamic> j) {
    return AdminCoinTxn(
      id: j['id'] as String,
      amount: ((j['amount'] as num?) ?? 0).toInt(),
      type: (j['type'] as String?) ?? 'EARN',
      userName: j['userName'] as String?,
      userEmail: j['userEmail'] as String?,
      companyName: j['companyName'] as String?,
      note: j['note'] as String?,
      createdAt: _date(j['createdAt']),
    );
  }
}

class CoinSummary {
  const CoinSummary({
    required this.circulating,
    required this.earned,
    required this.spent,
    required this.transactions,
  });

  final int circulating;
  final int earned;
  final int spent;
  final int transactions;

  factory CoinSummary.fromJson(Map<String, dynamic> j) {
    int g(String k) => ((j[k] as num?) ?? 0).toInt();
    return CoinSummary(
      circulating: g('circulating'),
      earned: g('earned'),
      spent: g('spent'),
      transactions: g('transactions'),
    );
  }
}

/// Lean pagination envelope matching the backend `PageResponse`.
class AdminPage<T> {
  const AdminPage({
    required this.content,
    required this.page,
    required this.totalElements,
    required this.totalPages,
  });

  final List<T> content;
  final int page;
  final int totalElements;
  final int totalPages;

  factory AdminPage.fromJson(
    Map<String, dynamic> j,
    T Function(Map<String, dynamic>) item,
  ) {
    return AdminPage<T>(
      content: ((j['content'] as List<dynamic>?) ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(item)
          .toList(growable: false),
      page: ((j['page'] as num?) ?? 0).toInt(),
      totalElements: ((j['totalElements'] as num?) ?? 0).toInt(),
      totalPages: ((j['totalPages'] as num?) ?? 0).toInt(),
    );
  }
}

DateTime? _date(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;

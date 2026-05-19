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
  });

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
  });

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

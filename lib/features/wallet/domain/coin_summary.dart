/// The customer's coin wallet snapshot, mirroring the backend
/// `CoinSummaryResponse`.
class CoinSummary {
  const CoinSummary({
    required this.total,
    required this.companies,
    required this.recent,
  });

  final int total;
  final List<CompanyBalance> companies;
  final List<CoinTxn> recent;

  static const CoinSummary empty =
      CoinSummary(total: 0, companies: <CompanyBalance>[], recent: <CoinTxn>[]);

  factory CoinSummary.fromJson(Map<String, dynamic> json) {
    return CoinSummary(
      total: ((json['total'] as num?) ?? 0).toInt(),
      companies: ((json['companies'] as List<dynamic>?) ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(CompanyBalance.fromJson)
          .toList(growable: false),
      recent: ((json['recent'] as List<dynamic>?) ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(CoinTxn.fromJson)
          .toList(growable: false),
    );
  }
}

class CompanyBalance {
  const CompanyBalance({
    required this.companyId,
    required this.companyName,
    required this.balance,
  });

  final String? companyId;
  final String companyName;
  final int balance;

  factory CompanyBalance.fromJson(Map<String, dynamic> json) => CompanyBalance(
        companyId: json['companyId'] as String?,
        companyName: (json['companyName'] as String?) ?? '',
        balance: ((json['balance'] as num?) ?? 0).toInt(),
      );
}

class CoinTxn {
  const CoinTxn({
    required this.id,
    required this.companyName,
    required this.amount,
    required this.type,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String? companyName;
  final int amount;
  final String type; // EARN | SPEND
  final String? note;
  final DateTime createdAt;

  bool get isEarn => type == 'EARN';

  factory CoinTxn.fromJson(Map<String, dynamic> json) => CoinTxn(
        id: (json['id'] as String?) ?? '',
        companyName: json['companyName'] as String?,
        amount: ((json['amount'] as num?) ?? 0).toInt(),
        type: (json['type'] as String?) ?? 'EARN',
        note: json['note'] as String?,
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
            DateTime.now(),
      );
}

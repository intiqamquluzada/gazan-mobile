import 'package:flutter/material.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/utils/money.dart';
import 'loyalty_card.dart';

/// What kind of reward a customer earns when they fill the card.
/// Wire form matches the backend enum (UPPER_SNAKE).
enum LoyaltyRewardType {
  freeItem('FREE_ITEM', 'Pulsuz məhsul', Icons.card_giftcard_rounded),
  percentageDiscount(
      'PERCENTAGE_DISCOUNT', 'Faiz endirim', Icons.percent_rounded),
  fixedDiscount('FIXED_DISCOUNT', 'Sabit endirim', Icons.discount_rounded),
  cashback('CASHBACK', 'Cashback', Icons.savings_rounded);

  const LoyaltyRewardType(this.wire, this.label, this.icon);

  final String wire;
  final String label;
  final IconData icon;

  /// Localized display label.
  String labelOf(S s) {
    switch (this) {
      case LoyaltyRewardType.freeItem:
        return s.rewardFreeItem;
      case LoyaltyRewardType.percentageDiscount:
        return s.rewardPercentDiscount;
      case LoyaltyRewardType.fixedDiscount:
        return s.rewardFixedDiscount;
      case LoyaltyRewardType.cashback:
        return s.rewardCashback;
    }
  }

  String toJson() => wire;

  static LoyaltyRewardType fromJson(String value) {
    for (final LoyaltyRewardType t in values) {
      if (t.wire == value) return t;
    }
    return LoyaltyRewardType.freeItem;
  }
}

class LoyaltyProgram {
  const LoyaltyProgram({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.stampsRequired,
    required this.rewardType,
    this.rewardValue,
    this.rewardItem = 'məhsul',
    this.expiresAt,
    this.isActive = true,
  });

  final String id;
  final String companyId;
  final String title;
  final String description;
  final int stampsRequired;
  final LoyaltyRewardType rewardType;
  final num? rewardValue;
  final String rewardItem;
  final DateTime? expiresAt;
  final bool isActive;

  /// False once the program is paused or past its end date: no new stamps.
  bool get isOpen =>
      isActive && (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  /// Stamps that fill [card]. A card keeps the number from when it was
  /// started, even if the owner changed the program since, so progress must
  /// be drawn against the card's own value whenever the customer has one.
  int stampsToFill(LoyaltyCard? card) => card?.stampsRequired ?? stampsRequired;

  /// Localized reward description, in the venue's own [currency].
  String rewardLabelOf(S s, {String? currency}) {
    final String money = Money.format(rewardValue ?? 0, currency);
    switch (rewardType) {
      case LoyaltyRewardType.freeItem:
        return '1 ${s.freeWord} $rewardItem';
      case LoyaltyRewardType.percentageDiscount:
        return '$rewardItem ${s.onWord} ${_fmt(rewardValue ?? 0)}% ${s.discountWord}';
      case LoyaltyRewardType.fixedDiscount:
        return '$rewardItem ${s.onWord} $money ${s.discountWord}';
      case LoyaltyRewardType.cashback:
        return '$money cashback';
    }
  }

  LoyaltyProgram copyWith({
    String? title,
    String? description,
    int? stampsRequired,
    LoyaltyRewardType? rewardType,
    num? rewardValue,
    String? rewardItem,
    bool? isActive,
    DateTime? expiresAt,
    bool clearExpiry = false,
  }) =>
      LoyaltyProgram(
        id: id,
        companyId: companyId,
        title: title ?? this.title,
        description: description ?? this.description,
        stampsRequired: stampsRequired ?? this.stampsRequired,
        rewardType: rewardType ?? this.rewardType,
        rewardValue: rewardValue ?? this.rewardValue,
        rewardItem: rewardItem ?? this.rewardItem,
        expiresAt: clearExpiry ? null : (expiresAt ?? this.expiresAt),
        isActive: isActive ?? this.isActive,
      );

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      stampsRequired: (json['stampsRequired'] as num).toInt(),
      rewardType: LoyaltyRewardType.fromJson(
          (json['rewardType'] as String?) ?? 'FREE_ITEM'),
      rewardValue: json['rewardValue'] as num?,
      rewardItem: (json['rewardItem'] as String?) ?? 'məhsul',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isActive: (json['active'] as bool?) ?? true,
    );
  }

  static String _fmt(num v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
}

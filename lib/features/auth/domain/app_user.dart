import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.birthDate,
    this.avatarUrl,
    this.businessId,
    this.profileComplete = true,
    this.staffCompanyId,
    this.hasPassword = true,
    this.notificationPrefs,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final DateTime? birthDate;
  final String? avatarUrl;
  final UserRole role;

  /// If this user owns/operates a business, the company id they manage.
  final String? businessId;

  /// False until the account has a phone number (social sign-ups start
  /// without one).
  final bool profileComplete;

  /// The venue a cashier works at.
  final String? staffCompanyId;

  /// False for Google / Apple accounts that never set a password: they set
  /// one without typing a current password.
  final bool hasPassword;

  /// Push switches as the server stores them (`rewards`, `offers`,
  /// `weekly`, `marketing`). Null from servers that predate them.
  final Map<String, bool>? notificationPrefs;

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? avatarUrl,
    UserRole? role,
    String? businessId,
    bool clearAvatar = false,
  }) =>
      AppUser(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        birthDate: birthDate ?? this.birthDate,
        avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
        role: role ?? this.role,
        businessId: businessId ?? this.businessId,
        profileComplete: profileComplete,
        staffCompanyId: staffCompanyId,
        hasPassword: hasPassword,
        notificationPrefs: notificationPrefs,
      );
}

import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.businessId,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;

  /// If this user owns/operates a business, the company id they manage.
  final String? businessId;

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    String? businessId,
  }) =>
      AppUser(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role ?? this.role,
        businessId: businessId ?? this.businessId,
      );
}

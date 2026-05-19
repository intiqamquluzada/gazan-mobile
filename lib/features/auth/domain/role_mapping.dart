import 'user_role.dart';

/// Translates between the mobile {@link UserRole} (binary customer/business)
/// and the backend's richer role enum (`CUSTOMER`, `BUSINESS_OWNER`, `ADMIN`).
class RoleMapping {
  const RoleMapping._();

  static UserRole fromBackend(String value) {
    switch (value) {
      case 'ADMIN':
        return UserRole.admin;
      case 'BUSINESS_OWNER':
        return UserRole.business;
      case 'CUSTOMER':
      default:
        return UserRole.customer;
    }
  }

  static String toBackend(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.business:
        return 'BUSINESS_OWNER';
      case UserRole.customer:
        return 'CUSTOMER';
    }
  }
}

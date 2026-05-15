import 'user_role.dart';

/// Translates between the mobile {@link UserRole} (binary customer/business)
/// and the backend's richer role enum (`CUSTOMER`, `BUSINESS_OWNER`, `ADMIN`).
class RoleMapping {
  const RoleMapping._();

  static UserRole fromBackend(String value) {
    switch (value) {
      case 'BUSINESS_OWNER':
      case 'ADMIN':
        return UserRole.business;
      case 'CUSTOMER':
      default:
        return UserRole.customer;
    }
  }

  static String toBackend(UserRole role) =>
      role == UserRole.business ? 'BUSINESS_OWNER' : 'CUSTOMER';
}

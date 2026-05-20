/// Whether the signed-in user is a customer collecting stamps, a business
/// owner running loyalty programs, or a platform admin.
enum UserRole { customer, business, admin }

extension UserRoleX on UserRole {
  /// The shell a user lands on after authenticating.
  String get landingPath {
    switch (this) {
      case UserRole.admin:
        return '/admin';
      case UserRole.business:
        return '/business';
      case UserRole.customer:
        return '/home';
    }
  }
}

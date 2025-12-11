// mobile/lib/src/data/models/user.dart
// Model representing a user in the POS system. example roles: owner manager cashier
class User {
  final String id;
  final String? email;
  final String name;
  final String phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final bool isVerified;
  final String? businessId;
  final String? passwordHash;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.isVerified = false,
    this.businessId,
    this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_login_at': lastLogin?.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
      'is_verified': isVerified ? 1 : 0,
      'business_id': businessId,
      'password_hash': passwordHash, // Add this line
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['user_id'],
      email: map['email'],
      name: map['name'],
      phone: map['phone'],
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      lastLogin: map['last_login_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_login_at'])
          : null,
      isActive: map['is_active'] == 1,
      isVerified: map['is_verified'] == 1,
      businessId: map['business_id'],
      passwordHash: map['password_hash'], // This should be here
    );
  }

  User copyWith({
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    bool? isActive,
    bool? isVerified,
    DateTime? lastLogin,
    String? passwordHash, // Add this parameter
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      businessId: businessId,
      passwordHash: passwordHash ?? this.passwordHash, // Include passwordHash
    );
  }

  bool get isOwner => role == UserRole.owner;
  bool get isManager => role == UserRole.manager;
  bool get isCashier => role == UserRole.cashier;
  bool get isAdmin => isOwner || isManager;

  bool hasPermission(Permission permission) {
    return role.permissions.contains(permission);
  }

  // Check if user can access specific features
  bool canManageUsers() => hasPermission(Permission.manageUsers);
  bool canManageProducts() => hasPermission(Permission.manageProducts);
  bool canManageCustomers() => hasPermission(Permission.manageCustomers);
  bool canViewReports() => hasPermission(Permission.viewReports);
  bool canProcessSales() => hasPermission(Permission.processSales);
}

enum UserRole {
  owner(
    'Owner',
    [
      Permission.manageUsers,
      Permission.manageProducts,
      Permission.manageCustomers,
      Permission.viewReports,
      Permission.processSales,
      Permission.manageSettings,
      Permission.viewDashboard,
    ],
  ),
  manager(
    'Manager',
    [
      Permission.manageProducts,
      Permission.manageCustomers,
      Permission.viewReports,
      Permission.processSales,
      Permission.viewDashboard,
    ],
  ),
  cashier(
    'Cashier',
    [
      Permission.processSales,
      Permission.viewDashboard,
    ],
  );

  final String displayName;
  final List<Permission> permissions;

  const UserRole(this.displayName, this.permissions);

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role.toLowerCase(),
      orElse: () => UserRole.cashier,
    );
  }
}

enum Permission {
  manageUsers('Manage Users'),
  manageProducts('Manage Products'),
  manageCustomers('Manage Customers'),
  viewReports('View Reports'),
  processSales('Process Sales'),
  manageSettings('Manage Settings'),
  viewDashboard('View Dashboard');

  final String displayName;

  const Permission(this.displayName);
}

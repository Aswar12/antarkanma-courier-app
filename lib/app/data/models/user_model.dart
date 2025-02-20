class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String role;
  final String? username;
  final String? profilePhotoUrl;
  final String? profilePhotoPath;
  final double balance; // New property

  static const String ROLE_USER = 'USER';
  static const String ROLE_COURIER = 'COURIER';

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    required this.role,
    this.username,
    this.profilePhotoUrl,
    this.profilePhotoPath,
    required this.balance, // Include in constructor
  });

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Cannot create UserModel from null');
    }

    // Safely get id with null check and type conversion
    int? id;
    if (json['id'] is int) {
      id = json['id'];
    } else if (json['id'] is String) {
      id = int.tryParse(json['id']);
    }
    if (id == null) {
      throw Exception('Invalid or missing user ID');
    }

    // Safely get name with null check
    String? name = json['name']?.toString();
    if (name == null || name.isEmpty) {
      throw Exception('Invalid or missing user name');
    }

    // Handle profile photo URL
    String? photoUrl = json['profile_photo_url']?.toString();
    if (photoUrl == null || photoUrl.isEmpty) {
      // If no photo URL, check if there's a path and construct the URL
      final photoPath = json['profile_photo_path']?.toString();
      if (photoPath != null && photoPath.isNotEmpty) {
        photoUrl = 'storage/$photoPath';
      }
    }

    // Handle role from different possible API response formats
    String role;
    var roleData = json['role'] ?? json['roles'];
    if (roleData != null) {
      if (roleData is List) {
        role = roleData.first.toString().toUpperCase();
      } else {
        role = roleData.toString().toUpperCase();
      }
    } else {
      role = ROLE_USER; // Default to USER role
    }

    // Safely get balance
    double balance = json['balance']?.toDouble() ?? 0.0;

    return UserModel(
      id: id,
      name: name,
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      role: role,
      username: json['username']?.toString(),
      profilePhotoUrl: photoUrl,
      profilePhotoPath: json['profile_photo_path']?.toString(),
      balance: balance, // Include balance
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'roles': role,
      'username': username,
      'profile_photo_url': profilePhotoUrl,
      'profile_photo_path': profilePhotoPath,
      'balance': balance, // Include balance in toJson
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.role == role &&
        other.username == username &&
        other.profilePhotoUrl == profilePhotoUrl &&
        other.profilePhotoPath == profilePhotoPath &&
        other.balance == balance; // Include balance in equality check
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        role.hashCode ^
        username.hashCode ^
        profilePhotoUrl.hashCode ^
        profilePhotoPath.hashCode ^
        balance.hashCode; // Include balance in hash code
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    String? username,
    String? profilePhotoUrl,
    String? profilePhotoPath,
    double? balance, // Include balance in copyWith
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      username: username ?? this.username,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      balance: balance ?? this.balance, // Include balance in copyWith
    );
  }

  // Helper methods
  bool get isUser => role == ROLE_USER;
  bool get isCourier => role == ROLE_COURIER;

  String get displayName => username ?? name;

  bool get hasProfilePhoto =>
      (profilePhotoUrl?.isNotEmpty ?? false) ||
      (profilePhotoPath?.isNotEmpty ?? false);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, role: $role, balance: $balance)';
  }
}

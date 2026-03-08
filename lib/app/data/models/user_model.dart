import 'package:flutter/foundation.dart';

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
  final int? courierId; // Courier ID for chat initiation
  final bool isActive; // Courier online/offline status

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
    this.courierId, // Include courier ID
    this.isActive = true, // Include courier active status
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

    // Safely get balance (API may return String or num)
    double balance = 0.0;
    if (json['balance'] != null) {
      balance = double.tryParse('${json['balance']}') ?? 0.0;
    }
    if (balance == 0.0 &&
        json['courier'] != null &&
        json['courier'] is Map<String, dynamic> &&
        json['courier']['wallet_balance'] != null) {
      balance = double.tryParse('${json['courier']['wallet_balance']}') ?? 0.0;
    }

    // Get courier ID from nested courier object (if backend sends it)
    // Backend sends: user: { id: 249, courier: { id: 21, ... } }
    int? courierId;
    if (json['courier'] != null && json['courier'] is Map<String, dynamic>) {
      final courierData = json['courier'] as Map<String, dynamic>;
      if (courierData['id'] is int) {
        courierId = courierData['id'];
      } else if (courierData['id'] is String) {
        courierId = int.tryParse(courierData['id']);
      }
      debugPrint(
          'UserModel: Extracted courier_id from courier object: $courierId');
    }

    // Get courier active status from nested courier object
    bool isActive = true;
    if (json['courier'] != null && json['courier'] is Map<String, dynamic>) {
      final courierData = json['courier'] as Map<String, dynamic>;
      isActive = courierData['is_active'] ?? true;
      debugPrint(
          'UserModel: Extracted courier is_active from courier object: $isActive');
    }

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
      courierId: courierId, // Extract from courier object
      isActive: isActive, // Extract from courier object
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
      'courier_id': courierId, // Include courier ID
      'is_active': isActive, // Include courier active status
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
        other.balance == balance && // Include balance in equality check
        other.courierId == courierId && // Include courier ID in equality check
        other.isActive ==
            isActive; // Include courier active status in equality check
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
        balance.hashCode ^
        courierId.hashCode ^
        isActive.hashCode; // Include courier active status in hash code
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
    int? courierId, // Include courier ID in copyWith
    bool? isActive, // Include courier active status in copyWith
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
      courierId: courierId ?? this.courierId, // Include courier ID in copyWith
      isActive: isActive ??
          this.isActive, // Include courier active status in copyWith
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

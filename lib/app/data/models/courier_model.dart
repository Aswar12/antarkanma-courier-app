import 'package:antarkanma/app/data/models/user_model.dart';

class CourierStatistics {
  final int activeTransactions;
  final int completedTransactions;
  final int totalTransactions;

  CourierStatistics({
    required this.activeTransactions,
    required this.completedTransactions,
    required this.totalTransactions,
  });

  factory CourierStatistics.fromJson(Map<String, dynamic> json) {
    return CourierStatistics(
      activeTransactions: json['active_transactions'] as int,
      completedTransactions: json['completed_transactions'] as int,
      totalTransactions: json['total_transactions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_transactions': activeTransactions,
      'completed_transactions': completedTransactions,
      'total_transactions': totalTransactions,
    };
  }
}

class CourierModel {
  final int id;
  final UserModel user;
  final String vehicleType;
  final String licensePlate;
  final String fullDetails;
  final CourierStatistics statistics;
  final List<dynamic> activeDeliveries; // You might want to create a specific model for this

  CourierModel({
    required this.id,
    required this.user,
    required this.vehicleType,
    required this.licensePlate,
    required this.fullDetails,
    required this.statistics,
    required this.activeDeliveries,
  });

  factory CourierModel.fromJson(Map<String, dynamic> json) {
    return CourierModel(
      id: json['id'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      vehicleType: json['vehicle_type'] as String,
      licensePlate: json['license_plate'] as String,
      fullDetails: json['full_details'] as String,
      statistics: CourierStatistics.fromJson(json['statistics'] as Map<String, dynamic>),
      activeDeliveries: json['active_deliveries'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'vehicle_type': vehicleType,
      'license_plate': licensePlate,
      'full_details': fullDetails,
      'statistics': statistics.toJson(),
      'active_deliveries': activeDeliveries,
    };
  }

  CourierModel copyWith({
    int? id,
    UserModel? user,
    String? vehicleType,
    String? licensePlate,
    String? fullDetails,
    CourierStatistics? statistics,
    List<dynamic>? activeDeliveries,
  }) {
    return CourierModel(
      id: id ?? this.id,
      user: user ?? this.user,
      vehicleType: vehicleType ?? this.vehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      fullDetails: fullDetails ?? this.fullDetails,
      statistics: statistics ?? this.statistics,
      activeDeliveries: activeDeliveries ?? this.activeDeliveries,
    );
  }
}

class FcmTokenModel {
  final String token;
  final String deviceType;
  final String deviceId;
  final int? userId;
  final String? createdAt;
  final String? updatedAt;
  final int? id;

  FcmTokenModel({
    required this.token,
    required this.deviceType,
    required this.deviceId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  factory FcmTokenModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenModel(
      token: json['token'],
      deviceType: json['device_type'],
      deviceId: json['device_id'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'device_type': deviceType,
      'device_id': deviceId,
    };
  }

  @override
  String toString() {
    return 'FcmTokenModel(token: $token, deviceType: $deviceType, deviceId: $deviceId)';
  }
}

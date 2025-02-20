class ProductReviewModel {
  final int? id;
  final int rating;
  final String comment;
  final String? userName;
  final String? userImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductReviewModel({
    this.id,
    required this.rating,
    required this.comment,
    this.userName,
    this.userImage,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      rating: json['rating'] is int ? json['rating'] : int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString() ?? '',
      userName: json['user_name']?.toString(),
      userImage: json['user_image']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'user_name': userName,
      'user_image': userImage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

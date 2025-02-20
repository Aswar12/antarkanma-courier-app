class ApiResponse<T> {
  final Meta meta;
  final T data;

  ApiResponse({
    required this.meta,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse<T>(
      meta: Meta.fromJson(json['meta']),
      data: fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJson) => {
    'meta': meta.toJson(),
    'data': toJson(data),
  };
}

class Meta {
  final int code;
  final String status;
  final String message;

  Meta({
    required this.code,
    required this.status,
    required this.message,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    code: json['code'],
    status: json['status'],
    message: json['message'],
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'status': status,
    'message': message,
  };
}

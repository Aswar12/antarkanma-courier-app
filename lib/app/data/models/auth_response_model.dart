import 'user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String tokenType;

  AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.tokenType,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => AuthResponseModel(
    user: UserModel.fromJson(json['user']),
    accessToken: json['access_token'],
    tokenType: json['token_type'],
  );

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'access_token': accessToken,
    'token_type': tokenType,
  };

  String get fullToken => '$tokenType $accessToken';
}

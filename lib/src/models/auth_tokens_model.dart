import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
    };
  }
}

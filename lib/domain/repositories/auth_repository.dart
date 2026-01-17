import '../../domain/entities/user.dart';
import '../../domain/entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<AuthTokens> login(String username, String password);
  Future<AuthTokens> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });
  Future<User> getCurrentUser();
  Future<void> logout();
}

import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../src/lib/token_storage.dart';
import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<AuthTokens> login(String username, String password) async {
    final tokens = await remoteDataSource.login(username, password);
    await tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  @override
  Future<AuthTokens> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final tokens = await remoteDataSource.register(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    await tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  @override
  Future<User> getCurrentUser() async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) {
      throw Exception('No hay token de acceso');
    }
    return await remoteDataSource.getCurrentUser(token);
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clearTokens();
  }
}

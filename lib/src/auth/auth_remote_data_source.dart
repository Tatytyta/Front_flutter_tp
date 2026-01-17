import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../src/config/api_constants.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource({required this.client});

  Future<AuthTokensModel> login(String username, String password) async {
    try {
      print('Intentando login con username: $username');
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: ApiConstants.jsonHeaders,
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        return AuthTokensModel.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        String errorMessage = 'Error al iniciar sesión';
        
        if (errorBody is Map && errorBody.containsKey('detail')) {
          errorMessage = errorBody['detail'];
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  Future<AuthTokensModel> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final registerResponse = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}'),
        headers: ApiConstants.jsonHeaders,
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'password2': password,
          'first_name': firstName ?? '',
          'last_name': lastName ?? '',
        }),
      );

      print('Register response status: ${registerResponse.statusCode}');
      print('Register response body: ${registerResponse.body}');

      if (registerResponse.statusCode == 201) {
        // Registro exitoso, ahora hacer login
        print('Registro exitoso, intentando login...');
        return await login(username, password);
      } else {
        final errorBody = json.decode(registerResponse.body);
        String errorMessage = 'Error al registrarse';
        
        if (errorBody is Map) {
          if (errorBody.containsKey('username')) {
            errorMessage = 'Usuario: ${errorBody['username'][0]}';
          } else if (errorBody.containsKey('email')) {
            errorMessage = 'Email: ${errorBody['email'][0]}';
          } else if (errorBody.containsKey('password')) {
            errorMessage = 'Contraseña: ${errorBody['password'][0]}';
          } else {
            errorMessage = errorBody.toString();
          }
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error en register: $e');
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser(String token) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userEndpoint}'),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener usuario: ${response.body}');
    }
  }
}

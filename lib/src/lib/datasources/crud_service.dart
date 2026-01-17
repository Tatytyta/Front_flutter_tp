import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_constants.dart';
import '../token_storage.dart';
import '../../../domain/entities/paginated_response.dart';

class CrudService<T> {
  final String endpoint;
  final T Function(Map<String, dynamic>) fromJson;
  final http.Client client;
  final TokenStorage tokenStorage;
  final bool requiresAuth;

  CrudService({
    required this.endpoint,
    required this.fromJson,
    required this.client,
    required this.tokenStorage,
    this.requiresAuth = false,
  });

  Future<Map<String, String>> _getHeaders() async {
    if (requiresAuth) {
      final token = await tokenStorage.getAccessToken();
      if (token == null) {
        throw Exception('No hay token de acceso');
      }
      return ApiConstants.authHeaders(token);
    }
    return ApiConstants.jsonHeaders;
  }

  Future<PaginatedResponse<T>> getAll() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PaginatedResponse<T>(
        count: data['count'] as int,
        next: data['next'] as String?,
        previous: data['previous'] as String?,
        results: (data['results'] as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } else {
      throw Exception('Error al obtener datos: ${response.body}');
    }
  }

  Future<T> getById(int id) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint$id/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener elemento: ${response.body}');
    }
  }

  Future<T> create(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear: ${response.body}');
    }
  }

  Future<T> update(int id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}$endpoint$id/'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar: ${response.body}');
    }
  }

  Future<void> delete(int id) async {
    final headers = await _getHeaders();
    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}$endpoint$id/'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar: ${response.body}');
    }
  }
}

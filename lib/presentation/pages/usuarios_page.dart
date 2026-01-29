import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/token_storage.dart';
import '../../domain/entities/user.dart';
import '../routing/require_admin.dart';
import '../widgets/common_widgets.dart';
import 'dart:convert';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<User> _usuarios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final token = await TokenStorage().getAccessToken();
      if (token == null) {
        throw Exception('No hay token disponible');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usuariosEndpoint}'),
        headers: ApiConstants.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> jsonList;
        
        // Verificar si la respuesta es paginada o una lista directa
        if (responseData is Map && responseData.containsKey('results')) {
          jsonList = responseData['results'];
        } else if (responseData is List) {
          jsonList = responseData;
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
        
        setState(() {
          _usuarios = jsonList.map((json) => User.fromJson(json)).toList();
          _loading = false;
        });
      } else {
        throw Exception('Error al cargar usuarios: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar usuarios: $e')),
        );
      }
    }
  }

  String _getRolLabel(User usuario) {
    if (usuario.isSuperuser == true) return '👑 Superusuario';
    if (usuario.isStaff == true) return '👨‍💼 Staff/Admin';
    return '👤 Usuario';
  }

  Color _getRolColor(User usuario) {
    if (usuario.isSuperuser == true) return const Color(0xFFe74c3c);
    if (usuario.isStaff == true) return const Color(0xFFe67e22);
    return const Color(0xFF3498db);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Ir al Dashboard',
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '👥',
                      style: TextStyle(fontSize: 48),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Usuarios del Sistema',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${_usuarios.length} usuarios registrados',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Users List
            _buildUsersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    if (_usuarios.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(48),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 80, color: Color(0xFF94A3B8)),
                SizedBox(height: 16),
                Text(
                  'No hay usuarios registrados',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: _usuarios.map((usuario) => _buildUserCard(usuario)).toList(),
    );
  }

  Widget _buildUserCard(User usuario) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getRolColor(usuario).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getRolColor(usuario),
                        _getRolColor(usuario).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      usuario.username.isNotEmpty
                          ? usuario.username[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${usuario.firstName ?? ''} ${usuario.lastName ?? ''}'
                            .trim()
                            .isEmpty
                            ? 'Sin nombre completo'
                            : '${usuario.firstName ?? ''} ${usuario.lastName ?? ''}'
                                .trim(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRolColor(usuario).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getRolColor(usuario),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _getRolLabel(usuario),
                    style: TextStyle(
                      color: _getRolColor(usuario),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, size: 18, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      usuario.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  Text(
                    'ID: ${usuario.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

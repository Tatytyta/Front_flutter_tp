import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../src/config/api_constants.dart';
import '../../src/lib/token_storage.dart';
import '../../domain/entities/user.dart';
import '../require_admin.dart';
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
    if (usuario.isSuperuser == true) return 'Superusuario';
    if (usuario.isStaff == true) return 'Admin';
    return 'Usuario';
  }

  Color _getRolColor(User usuario) {
    if (usuario.isSuperuser == true) return const Color(0xFFe74c3c);
    if (usuario.isStaff == true) return const Color(0xFFe67e22);
    return const Color(0xFF3498db);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: const Color(0xFF34495e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.people, size: 48, color: Color(0xFF3498db)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuarios del Sistema',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text('Total: ${_usuarios.length} usuarios'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (_usuarios.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay usuarios registrados'),
          ),
        ),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF34495e)),
          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Usuario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Nombre Completo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Rol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: _usuarios.map((usuario) {
            return DataRow(
              cells: [
                DataCell(Text(usuario.id.toString())),
                DataCell(Text(usuario.username)),
                DataCell(Text(
                  '${usuario.firstName ?? ''} ${usuario.lastName ?? ''}'.trim().isEmpty
                      ? 'N/A'
                      : '${usuario.firstName ?? ''} ${usuario.lastName ?? ''}'.trim()
                )),
                DataCell(Text(usuario.email)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRolColor(usuario).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getRolColor(usuario)),
                    ),
                    child: Text(
                      _getRolLabel(usuario),
                      style: TextStyle(
                        color: _getRolColor(usuario),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

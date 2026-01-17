import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../src/lib/token_storage.dart';
import '../../src/lib/datasources/crud_service.dart';
import '../../src/config/api_constants.dart';
import '../../domain/entities/tarjeta.dart';
import '../../src/auth/auth_provider.dart';

class TarjetasPage extends StatefulWidget {
  const TarjetasPage({super.key});

  @override
  State<TarjetasPage> createState() => _TarjetasPageState();
}

class _TarjetasPageState extends State<TarjetasPage> {
  late final CrudService<Tarjeta> _tarjetaService;
  List<Tarjeta> _tarjetas = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  
  final _numeroController = TextEditingController();
  final _saldoController = TextEditingController();
  final _fechaExpiracionController = TextEditingController();
  bool _activa = true;

  @override
  void initState() {
    super.initState();
    _tarjetaService = CrudService<Tarjeta>(
      endpoint: ApiConstants.tarjetasEndpoint,
      fromJson: (json) => Tarjeta.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _loadTarjetas();
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _saldoController.dispose();
    _fechaExpiracionController.dispose();
    super.dispose();
  }

  Future<void> _loadTarjetas() async {
    setState(() => _loading = true);
    try {
      final response = await _tarjetaService.getAll();
      setState(() {
        _tarjetas = response.results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar tarjetas: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_numeroController.text.isEmpty || _saldoController.text.isEmpty || _fechaExpiracionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son requeridos')),
      );
      return;
    }

    int? userId;
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe iniciar sesión primero')),
      );
      return;
    }

    if (authProvider.user != null) {
      userId = authProvider.user!.id;
      print('User ID obtenido de AuthProvider: $userId');
    } else {
      print('Usuario no disponible en AuthProvider, intentando obtener del token...');
      final token = await TokenStorage().getAccessToken();
      if (token != null) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            final normalized = base64Url.normalize(payload);
            final decoded = utf8.decode(base64Url.decode(normalized));
            final Map<String, dynamic> payloadMap = json.decode(decoded);
            print('Payload del token: $payloadMap');
            final userIdValue = payloadMap['user_id'];
            userId = userIdValue is int ? userIdValue : (userIdValue is String ? int.tryParse(userIdValue) : null);
            print('User ID del token: $userId');
          }
        } catch (e) {
          print('Error decodificando token: $e');
        }
      } else {
        print('No hay token disponible');
      }
      
      if (userId == null) {
        await authProvider.checkAuthStatus();
        if (authProvider.user != null) {
          userId = authProvider.user!.id;
          print('User ID obtenido después de checkAuthStatus: $userId');
        }
      }
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el ID de usuario. Intente cerrar sesión y volver a ingresar.'),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    final data = {
      'usuario': userId,
      'numero': _numeroController.text,
      'saldo': double.parse(_saldoController.text),
      'fecha_expiracion': _fechaExpiracionController.text,
      'activa': _activa,
    };

    try {
      if (_editingId != null) {
        await _tarjetaService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Tarjeta actualizada correctamente')),
          );
        }
      } else {
        await _tarjetaService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Tarjeta creada correctamente')),
          );
        }
      }
      _resetForm();
      _loadTarjetas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }

  void _handleEdit(Tarjeta tarjeta) {
    setState(() {
      _editingId = tarjeta.id;
      _numeroController.text = tarjeta.numero;
      _saldoController.text = tarjeta.saldo;
      _fechaExpiracionController.text = tarjeta.fechaExpiracion;
      _activa = tarjeta.activa;
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar esta tarjeta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _tarjetaService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Tarjeta eliminada')),
          );
        }
        _loadTarjetas();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  void _resetForm() {
    setState(() {
      _numeroController.clear();
      _saldoController.clear();
      _fechaExpiracionController.clear();
      _activa = true;
      _editingId = null;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tarjetas'),
        backgroundColor: const Color(0xFF8e44ad),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
            tooltip: _showForm ? 'Cancelar' : 'Nueva Tarjeta',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_showForm) _buildForm(),
                  const SizedBox(height: 16),
                  _buildList(),
                ],
              ),
            ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingId != null ? 'Editar Tarjeta' : 'Nueva Tarjeta',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numeroController,
              decoration: const InputDecoration(
                labelText: 'Número de Tarjeta *',
                hintText: 'Ej: 1234567890',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _saldoController,
              decoration: const InputDecoration(
                labelText: 'Saldo *',
                hintText: 'Ej: 50.00',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fechaExpiracionController,
              decoration: const InputDecoration(
                labelText: 'Fecha de Expiración *',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  _fechaExpiracionController.text = date.toIso8601String().split('T')[0];
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Tarjeta Activa'),
              value: _activa,
              onChanged: (value) => setState(() => _activa = value ?? true),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498db),
                  ),
                  child: const Text('Guardar'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _resetForm,
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_tarjetas.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay tarjetas registradas'),
          ),
        ),
      );
    }

    return Column(
      children: _tarjetas.map((tarjeta) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF8e44ad),
              child: Icon(Icons.credit_card, color: Colors.white),
            ),
            title: Text(
              'Tarjeta ${tarjeta.numero}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Saldo: \$${tarjeta.saldo}'),
                Text('Expira: ${tarjeta.fechaExpiracion}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(
                    tarjeta.activa ? 'Activa' : 'Inactiva',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: tarjeta.activa ? const Color(0xFF2ecc71) : const Color(0xFFe74c3c),
                  padding: EdgeInsets.zero,
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFFf39c12)),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Color(0xFFe74c3c)),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _handleEdit(tarjeta);
                    } else if (value == 'delete') {
                      _handleDelete(tarjeta.id!);
                    }
                  },
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }
}

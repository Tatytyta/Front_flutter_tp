import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/token_storage.dart';
import '../../data/datasources/crud_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/ruta.dart';
import '../../domain/entities/linea.dart';

class RutasPage extends StatefulWidget {
  const RutasPage({super.key});

  @override
  State<RutasPage> createState() => _RutasPageState();
}

class _RutasPageState extends State<RutasPage> {
  late final CrudService<Ruta> _rutaService;
  late final CrudService<Linea> _lineaService;
  List<Ruta> _rutas = [];
  List<Linea> _lineas = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  int? _selectedLineaNumero;

  @override
  void initState() {
    super.initState();
    _rutaService = CrudService<Ruta>(
      endpoint: ApiConstants.rutasEndpoint,
      fromJson: (json) => Ruta.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _lineaService = CrudService<Linea>(
      endpoint: ApiConstants.lineasEndpoint,
      fromJson: (json) => Linea.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _loadData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final rutasResponse = await _rutaService.getAll();
      final lineasResponse = await _lineaService.getAll();
      setState(() {
        _rutas = rutasResponse.results;
        _lineas = lineasResponse.results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_nombreController.text.isEmpty || _selectedLineaNumero == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y Línea son requeridos')),
      );
      return;
    }

    final data = {
      // Backend espera clave linea_numero (PK int); las líneas pueden venir de Mongo.
      'linea_numero': _selectedLineaNumero!,
      'nombre': _nombreController.text,
      'descripcion': _descripcionController.text.isEmpty ? null : _descripcionController.text,
    };

    try {
      if (_editingId != null) {
        await _rutaService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Ruta actualizada')),
          );
        }
      } else {
        await _rutaService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Ruta creada')),
          );
        }
      }
      _resetForm();
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }

  void _handleEdit(Ruta ruta) {
    setState(() {
      _editingId = ruta.id;
      _selectedLineaNumero = ruta.lineaNumero ?? int.tryParse(ruta.linea);
      _nombreController.text = ruta.nombre;
      _descripcionController.text = ruta.descripcion ?? '';
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Eliminar esta ruta?'),
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
        await _rutaService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Ruta eliminada')),
          );
        }
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _resetForm() {
    setState(() {
      _nombreController.clear();
      _descripcionController.clear();
      _selectedLineaNumero = null;
      _editingId = null;
      _showForm = false;
    });
  }

  String _getLineaNombre(int lineaNumero) {
    final linea = _lineas.where((l) => l.numero == lineaNumero).firstOrNull;
    return linea != null ? '${linea.numero} - ${linea.nombre}' : 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas'),
        backgroundColor: const Color(0xFF9b59b6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
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
              _editingId != null ? 'Editar Ruta' : 'Nueva Ruta',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedLineaNumero,
              decoration: const InputDecoration(
                labelText: 'Línea *',
                border: OutlineInputBorder(),
              ),
              items: _lineas.map((linea) {
                return DropdownMenuItem(
                  value: linea.numero,
                  child: Text('${linea.numero} - ${linea.nombre}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedLineaNumero = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
    if (_rutas.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay rutas registradas'),
          ),
        ),
      );
    }

    return Column(
      children: _rutas.map((ruta) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF9b59b6),
              child: Icon(Icons.map, color: Colors.white),
            ),
            title: Text(ruta.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Línea: ${_getLineaNombre(ruta.linea)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
                  onPressed: () => _handleEdit(ruta),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                  onPressed: () => _handleDelete(ruta.id!),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

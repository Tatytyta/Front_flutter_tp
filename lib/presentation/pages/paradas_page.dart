import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/token_storage.dart';
import '../../data/datasources/crud_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/parada.dart';
import '../widgets/common_widgets.dart';

class ParadasPage extends StatefulWidget {
  const ParadasPage({super.key});

  @override
  State<ParadasPage> createState() => _ParadasPageState();
}

class _ParadasPageState extends State<ParadasPage> {
  late final CrudService<Parada> _paradaService;
  List<Parada> _paradas = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paradaService = CrudService<Parada>(
      endpoint: ApiConstants.paradasEndpoint,
      fromJson: (json) => Parada.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _loadParadas();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  Future<void> _loadParadas() async {
    setState(() => _loading = true);
    try {
      final response = await _paradaService.getAll();
      setState(() {
        _paradas = response.results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar paradas: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_nombreController.text.isEmpty || _direccionController.text.isEmpty ||
        _latitudController.text.isEmpty || _longitudController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son requeridos')),
      );
      return;
    }

    final data = {
      'nombre': _nombreController.text,
      'direccion': _direccionController.text,
      'latitud': double.parse(_latitudController.text),
      'longitud': double.parse(_longitudController.text),
    };

    try {
      if (_editingId != null) {
        await _paradaService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Parada actualizada correctamente')),
          );
        }
      } else {
        await _paradaService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Parada creada correctamente')),
          );
        }
      }
      _resetForm();
      _loadParadas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }

  void _handleEdit(Parada parada) {
    setState(() {
      _editingId = parada.id;
      _nombreController.text = parada.nombre;
      _direccionController.text = parada.direccion;
      _latitudController.text = parada.latitud.toString();
      _longitudController.text = parada.longitud.toString();
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar esta parada?'),
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
        await _paradaService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Parada eliminada')),
          );
        }
        _loadParadas();
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
      _nombreController.clear();
      _direccionController.clear();
      _latitudController.clear();
      _longitudController.clear();
      _editingId = null;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paradas'),
        backgroundColor: const Color(0xFF2ecc71),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
            tooltip: _showForm ? 'Cancelar' : 'Nueva Parada',
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
                  _buildTable(),
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
              _editingId != null ? 'Editar Parada' : 'Nueva Parada',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                hintText: 'Ej: Plaza Central',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección *',
                hintText: 'Ej: Av. Principal 123',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latitudController,
                    decoration: const InputDecoration(
                      labelText: 'Latitud *',
                      hintText: 'Ej: -12.0464',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _longitudController,
                    decoration: const InputDecoration(
                      labelText: 'Longitud *',
                      hintText: 'Ej: -77.0428',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
              ],
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

  Widget _buildTable() {
    if (_paradas.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay paradas registradas'),
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
            DataColumn(label: Text('Nombre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Dirección', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Coordenadas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Acciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: _paradas.map((parada) {
            return DataRow(
              cells: [
                DataCell(Text(parada.nombre)),
                DataCell(Text(parada.direccion)),
                DataCell(Text('${parada.latitud?.toStringAsFixed(4) ?? 'N/A'}, ${parada.longitud?.toStringAsFixed(4) ?? 'N/A'}')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
                        onPressed: () => _handleEdit(parada),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                        onPressed: () => _handleDelete(parada.id!),
                        tooltip: 'Eliminar',
                      ),
                    ],
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

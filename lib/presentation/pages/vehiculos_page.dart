import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/token_storage.dart';
import '../../data/datasources/crud_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/vehiculo.dart';
import '../../domain/entities/linea.dart';
import '../widgets/common_widgets.dart';

class VehiculosPage extends StatefulWidget {
  const VehiculosPage({super.key});

  @override
  State<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends State<VehiculosPage> {
  late final CrudService<Vehiculo> _vehiculoService;
  late final CrudService<Linea> _lineaService;
  List<Vehiculo> _vehiculos = [];
  List<Linea> _lineas = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  
  final _patenteController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _anioController = TextEditingController(text: DateTime.now().year.toString());

  @override
  void initState() {
    super.initState();
    _vehiculoService = CrudService<Vehiculo>(
      endpoint: ApiConstants.vehiculosEndpoint,
      fromJson: (json) => Vehiculo.fromJson(json),
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
    _patenteController.dispose();
    _modeloController.dispose();
    _capacidadController.dispose();
    _anioController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final vehiculosResponse = await _vehiculoService.getAll();
      final lineasResponse = await _lineaService.getAll();
      setState(() {
        _vehiculos = vehiculosResponse.results;
        _lineas = lineasResponse.results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_patenteController.text.isEmpty ||
        _capacidadController.text.isEmpty || _anioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son requeridos')),
      );
      return;
    }

    final data = {
      'patente': _patenteController.text,
      'marca': _marcaController.text.isEmpty ? null : _marcaController.text,
      'modelo': _modeloController.text.isEmpty ? null : _modeloController.text,
      'capacidad': int.parse(_capacidadController.text),
      'anio': int.parse(_anioController.text),
    };

    try {
      if (_editingId != null) {
        await _vehiculoService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Vehículo actualizado correctamente')),
          );
        }
      } else {
        await _vehiculoService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Vehículo creado correctamente')),
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

  void _handleEdit(Vehiculo vehiculo) {
    setState(() {
      _editingId = vehiculo.id;
      _patenteController.text = vehiculo.patente;
      _marcaController.text = vehiculo.marca ?? '';
      _modeloController.text = vehiculo.modelo ?? '';
      _capacidadController.text = vehiculo.capacidad.toString();
      _anioController.text = vehiculo.anio?.toString() ?? '';
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este vehículo?'),
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
        await _vehiculoService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Vehículo eliminado')),
          );
        }
        _loadData();
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
      _patenteController.clear();
      _marcaController.clear();
      _modeloController.clear();
      _capacidadController.clear();
      _anioController.text = DateTime.now().year.toString();
      _editingId = null;
      _showForm = false;
    });
  }

  String _getLineaNombre(int lineaId) {
    final linea = _lineas.where((l) => l.id == lineaId).firstOrNull;
    return linea != null ? '${linea.numero} - ${linea.nombre}' : 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
        backgroundColor: const Color(0xFFe67e22),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
            tooltip: _showForm ? 'Cancelar' : 'Nuevo Vehículo',
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
              _editingId != null ? 'Editar Vehículo' : 'Nuevo Vehículo',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _patenteController,
                    decoration: const InputDecoration(
                      labelText: 'Patente *',
                      hintText: 'Ej: ABC123',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _modeloController,
                    decoration: const InputDecoration(
                      labelText: 'Modelo *',
                      hintText: 'Ej: Mercedes Benz',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _capacidadController,
                    decoration: const InputDecoration(
                      labelText: 'Capacidad *',
                      hintText: 'Ej: 40',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _anioController,
                    decoration: const InputDecoration(
                      labelText: 'Año *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
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
    if (_vehiculos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay vehículos registrados'),
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
            DataColumn(label: Text('Patente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Marca', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Modelo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Capacidad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Año', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Acciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: _vehiculos.map((vehiculo) {
            return DataRow(
              cells: [
                DataCell(Text(vehiculo.patente)),
                DataCell(Text(vehiculo.marca ?? 'N/A')),
                DataCell(Text(vehiculo.modelo ?? 'N/A')),
                DataCell(Text(vehiculo.capacidad.toString())),
                DataCell(Text(vehiculo.anio?.toString() ?? 'N/A')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
                        onPressed: () => _handleEdit(vehiculo),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                        onPressed: () => _handleDelete(vehiculo.id!),
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

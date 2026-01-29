import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/token_storage.dart';
import '../../data/datasources/crud_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/mantenimiento.dart';
import '../../domain/entities/vehiculo.dart';

class MantenimientosPage extends StatefulWidget {
  const MantenimientosPage({super.key});

  @override
  State<MantenimientosPage> createState() => _MantenimientosPageState();
}

class _MantenimientosPageState extends State<MantenimientosPage> {
  late final CrudService<Mantenimiento> _mantenimientoService;
  late final CrudService<Vehiculo> _vehiculoService;
  List<Mantenimiento> _mantenimientos = [];
  List<Vehiculo> _vehiculos = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  
  int? _selectedVehiculo;
  String _tipo = 'Preventivo';
  DateTime _fecha = DateTime.now();
  final _descripcionController = TextEditingController();
  final _costoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mantenimientoService = CrudService<Mantenimiento>(
      endpoint: ApiConstants.mantenimientosEndpoint,
      fromJson: (json) => Mantenimiento.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _vehiculoService = CrudService<Vehiculo>(
      endpoint: ApiConstants.vehiculosEndpoint,
      fromJson: (json) => Vehiculo.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _loadData();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _costoController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final mantenimientosResponse = await _mantenimientoService.getAll();
      final vehiculosResponse = await _vehiculoService.getAll();
      setState(() {
        _mantenimientos = mantenimientosResponse.results;
        _vehiculos = vehiculosResponse.results;
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
    if (_selectedVehiculo == null || _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo y Descripción son requeridos')),
      );
      return;
    }

    final data = {
      'vehiculo': _selectedVehiculo!,
      'tipo': _tipo,
      'descripcion': _descripcionController.text,
      'fecha': _fecha.toIso8601String().split('T')[0],
      'costo': _costoController.text.isEmpty ? null : double.parse(_costoController.text),
    };

    try {
      if (_editingId != null) {
        await _mantenimientoService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Mantenimiento actualizado')),
          );
        }
      } else {
        await _mantenimientoService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Mantenimiento creado')),
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

  void _handleEdit(Mantenimiento mantenimiento) {
    setState(() {
      _editingId = mantenimiento.id;
      _selectedVehiculo = mantenimiento.vehiculo;
      _tipo = mantenimiento.tipo;
      _descripcionController.text = mantenimiento.descripcion;
      _fecha = DateTime.parse(mantenimiento.fecha);
      _costoController.text = mantenimiento.costo?.toString() ?? '';
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Eliminar este mantenimiento?'),
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
        await _mantenimientoService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Mantenimiento eliminado')),
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
      _selectedVehiculo = null;
      _tipo = 'Preventivo';
      _descripcionController.clear();
      _fecha = DateTime.now();
      _costoController.clear();
      _editingId = null;
      _showForm = false;
    });
  }

  String _getVehiculoInfo(int vehiculoId) {
    final vehiculo = _vehiculos.where((v) => v.id == vehiculoId).firstOrNull;
    return vehiculo != null ? '${vehiculo.patente} - ${vehiculo.modelo}' : 'N/A';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _fecha = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimientos'),
        backgroundColor: const Color(0xFFd35400),
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
              _editingId != null ? 'Editar Mantenimiento' : 'Nuevo Mantenimiento',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedVehiculo,
              decoration: const InputDecoration(
                labelText: 'Vehículo *',
                border: OutlineInputBorder(),
              ),
              items: _vehiculos.map((vehiculo) {
                return DropdownMenuItem(
                  value: vehiculo.id,
                  child: Text('${vehiculo.patente} - ${vehiculo.modelo}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedVehiculo = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Preventivo', child: Text('Preventivo')),
                      DropdownMenuItem(value: 'Correctivo', child: Text('Correctivo')),
                    ],
                    onChanged: (value) => setState(() => _tipo = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _costoController,
              decoration: const InputDecoration(
                labelText: 'Costo',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
    if (_mantenimientos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay mantenimientos registrados'),
          ),
        ),
      );
    }

    return Column(
      children: _mantenimientos.map((mantenimiento) {
        final fecha = DateTime.parse(mantenimiento.fecha);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: mantenimiento.tipo == 'Preventivo' 
                ? Colors.green 
                : Colors.orange,
              child: const Icon(Icons.build, color: Colors.white),
            ),
            title: Text(_getVehiculoInfo(mantenimiento.vehiculo), 
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo: ${mantenimiento.tipo}'),
                Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}'),
                if (mantenimiento.costo != null)
                  Text('Costo: \$${double.tryParse(mantenimiento.costo ?? '0')?.toStringAsFixed(2) ?? mantenimiento.costo}'),
                if (mantenimiento.descripcion != null)
                  Text(mantenimiento.descripcion!, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
                  onPressed: () => _handleEdit(mantenimiento),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                  onPressed: () => _handleDelete(mantenimiento.id!),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

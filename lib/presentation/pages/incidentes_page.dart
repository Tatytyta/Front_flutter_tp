import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/token_storage.dart';
import '../../data/datasources/crud_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/incidente.dart';
import '../../domain/entities/viaje.dart';

class IncidentesPage extends StatefulWidget {
  const IncidentesPage({super.key});

  @override
  State<IncidentesPage> createState() => _IncidentesPageState();
}

class _IncidentesPageState extends State<IncidentesPage> {
  late final CrudService<Incidente> _incidenteService;
  late final CrudService<Viaje> _viajeService;
  List<Incidente> _incidentes = [];
  List<Viaje> _viajes = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  
  int? _selectedViaje;
  final _descripcionController = TextEditingController();
  String _gravedad = 'Baja';
  bool _resuelto = false;

  @override
  void initState() {
    super.initState();
    _incidenteService = CrudService<Incidente>(
      endpoint: ApiConstants.incidentesEndpoint,
      fromJson: (json) => Incidente.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _viajeService = CrudService<Viaje>(
      endpoint: ApiConstants.viajesEndpoint,
      fromJson: (json) => Viaje.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _loadData();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final incidentesResponse = await _incidenteService.getAll();
      final viajesResponse = await _viajeService.getAll();
      setState(() {
        _incidentes = incidentesResponse.results;
        _viajes = viajesResponse.results;
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
    if (_descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descripción es requerida')),
      );
      return;
    }

    final data = {
      if (_selectedViaje != null) 'viaje': _selectedViaje,
      'descripcion': _descripcionController.text,
      'fecha_incidente': DateTime.now().toIso8601String(),
      'gravedad': _gravedad,
      'resuelto': _resuelto,
    };

    try {
      if (_editingId != null) {
        await _incidenteService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Incidente actualizado')),
          );
        }
      } else {
        await _incidenteService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Incidente creado')),
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

  void _handleEdit(Incidente incidente) {
    setState(() {
      _editingId = incidente.id;
      _selectedViaje = incidente.viaje;
      _descripcionController.text = incidente.descripcion;
      _gravedad = incidente.gravedad;
      _resuelto = incidente.resuelto;
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Eliminar este incidente?'),
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
        await _incidenteService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Incidente eliminado')),
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
      _selectedViaje = null;
      _descripcionController.clear();
      _gravedad = 'Baja';
      _resuelto = false;
      _editingId = null;
      _showForm = false;
    });
  }

  String _getViajeInfo(int? viajeId) {
    if (viajeId == null) return 'General';
    return 'Viaje #$viajeId';
  }

  Color _getGravedadColor(String gravedad) {
    switch (gravedad.toLowerCase()) {
      case 'baja': return Colors.green;
      case 'media': return Colors.orange;
      case 'alta': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidentes'),
        backgroundColor: const Color(0xFFc0392b),
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
              _editingId != null ? 'Editar Incidente' : 'Nuevo Incidente',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              value: _selectedViaje,
              decoration: const InputDecoration(
                labelText: 'Viaje (opcional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('General / Sin viaje')),
                ..._viajes.map((viaje) {
                  return DropdownMenuItem(
                    value: viaje.id,
                    child: Text('Viaje #${viaje.id}'),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedViaje = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gravedad,
              decoration: const InputDecoration(
                labelText: 'Gravedad *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                DropdownMenuItem(value: 'Media', child: Text('Media')),
                DropdownMenuItem(value: 'Alta', child: Text('Alta')),
              ],
              onChanged: (value) => setState(() => _gravedad = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Incidente resuelto'),
              value: _resuelto,
              onChanged: (value) => setState(() => _resuelto = value ?? false),
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
    if (_incidentes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay incidentes registrados'),
          ),
        ),
      );
    }

    return Column(
      children: _incidentes.map((incidente) {
        final fecha = DateTime.parse(incidente.fecha);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getGravedadColor(incidente.gravedad),
              child: const Icon(Icons.warning, color: Colors.white),
            ),
            title: Text(incidente.descripcion, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Viaje: ${_getViajeInfo(incidente.viaje)}'),
                Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}'),
                Text('Gravedad: ${incidente.gravedad}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: incidente.resuelto ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: incidente.resuelto ? Colors.green : Colors.red),
                  ),
                  child: Text(
                    incidente.resuelto ? 'Resuelto' : 'Pendiente',
                    style: TextStyle(
                      color: incidente.resuelto ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
                  onPressed: () => _handleEdit(incidente),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                  onPressed: () => _handleDelete(incidente.id!),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

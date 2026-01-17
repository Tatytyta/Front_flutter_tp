import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../src/lib/token_storage.dart';
import '../../src/lib/datasources/crud_service.dart';
import '../../src/config/api_constants.dart';
import '../../domain/entities/viaje.dart';
import '../../domain/entities/ruta.dart';
import '../../domain/entities/vehiculo.dart';
import '../../domain/entities/chofer.dart';

class ViajesPage extends StatefulWidget {
  const ViajesPage({super.key});

  @override
  State<ViajesPage> createState() => _ViajesPageState();
}

class _ViajesPageState extends State<ViajesPage> {
  late final CrudService<Viaje> _viajeService;
  late final CrudService<Ruta> _rutaService;
  late final CrudService<Vehiculo> _vehiculoService;
  late final CrudService<Chofer> _choferService;
  List<Viaje> _viajes = [];
  List<Ruta> _rutas = [];
  List<Vehiculo> _vehiculos = [];
  List<Chofer> _choferes = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  
  int? _selectedRuta;
  int? _selectedVehiculo;
  int? _selectedChofer;
  DateTime _fecha = DateTime.now();
  final _horaSalidaController = TextEditingController();
  final _horaLlegadaController = TextEditingController();
  String _estado = 'Programado';

  @override
  void initState() {
    super.initState();
    _viajeService = CrudService<Viaje>(
      endpoint: ApiConstants.viajesEndpoint,
      fromJson: (json) => Viaje.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _rutaService = CrudService<Ruta>(
      endpoint: ApiConstants.rutasEndpoint,
      fromJson: (json) => Ruta.fromJson(json),
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
    _choferService = CrudService<Chofer>(
      endpoint: ApiConstants.choferesEndpoint,
      fromJson: (json) => Chofer.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _loadData();
  }

  @override
  void dispose() {
    _horaSalidaController.dispose();
    _horaLlegadaController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final viajesResponse = await _viajeService.getAll();
      final rutasResponse = await _rutaService.getAll();
      final vehiculosResponse = await _vehiculoService.getAll();
      final choferesResponse = await _choferService.getAll();
      setState(() {
        _viajes = viajesResponse.results;
        _rutas = rutasResponse.results;
        _vehiculos = vehiculosResponse.results;
        _choferes = choferesResponse.results;
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
    if (_selectedRuta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruta es requerida')),
      );
      return;
    }

    final fechaSalida = DateTime(
      _fecha.year,
      _fecha.month,
      _fecha.day,
      _horaSalidaController.text.isNotEmpty ? int.parse(_horaSalidaController.text.split(':')[0]) : 0,
      _horaSalidaController.text.isNotEmpty ? int.parse(_horaSalidaController.text.split(':')[1]) : 0,
    );

    DateTime? fechaLlegada;
    if (_horaLlegadaController.text.isNotEmpty) {
      fechaLlegada = DateTime(
        _fecha.year,
        _fecha.month,
        _fecha.day,
        int.parse(_horaLlegadaController.text.split(':')[0]),
        int.parse(_horaLlegadaController.text.split(':')[1]),
      );
    }

    final data = {
      'ruta': _selectedRuta!,
      'vehiculo': _selectedVehiculo ?? (_vehiculos.isNotEmpty ? _vehiculos[0].id : null),
      'chofer': _selectedChofer ?? (_choferes.isNotEmpty ? _choferes[0].id : null),
      'fecha': '${_fecha.year}-${_fecha.month.toString().padLeft(2, '0')}-${_fecha.day.toString().padLeft(2, '0')}',
      if (_horaSalidaController.text.isNotEmpty) 'hora_salida_real': _horaSalidaController.text + ':00',
      if (_horaLlegadaController.text.isNotEmpty) 'hora_llegada_real': _horaLlegadaController.text + ':00',
      'estado': _estado,
    };

    try {
      if (_editingId != null) {
        await _viajeService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Viaje actualizado')),
          );
        }
      } else {
        await _viajeService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Viaje creado')),
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

  void _handleEdit(Viaje viaje) {
    setState(() {
      _editingId = viaje.id;
      _selectedRuta = viaje.ruta;
      _selectedVehiculo = viaje.vehiculo;
      _selectedChofer = viaje.chofer;
      _fecha = DateTime.parse(viaje.fecha);
      _horaSalidaController.text = viaje.horaSalidaReal ?? '';
      _horaLlegadaController.text = viaje.horaLlegadaReal ?? '';
      _estado = viaje.estado;
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Eliminar este viaje?'),
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
        await _viajeService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Viaje eliminado')),
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
      _selectedRuta = null;
      _selectedVehiculo = null;
      _selectedChofer = null;
      _fecha = DateTime.now();
      _horaSalidaController.clear();
      _horaLlegadaController.clear();
      _estado = 'Programado';
      _editingId = null;
      _showForm = false;
    });
  }

  String _getRutaNombre(int rutaId) {
    final ruta = _rutas.where((r) => r.id == rutaId).firstOrNull;
    return ruta?.nombre ?? 'N/A';
  }

  String _getVehiculoInfo(int vehiculoId) {
    final vehiculo = _vehiculos.where((v) => v.id == vehiculoId).firstOrNull;
    return vehiculo?.patente ?? 'N/A';
  }

  String _getChoferInfo(int choferId) {
    final chofer = _choferes.where((c) => c.id == choferId).firstOrNull;
    return chofer != null ? '${chofer.apellido}, ${chofer.nombre}' : 'N/A';
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'programado': return Colors.blue;
      case 'en curso': return Colors.orange;
      case 'finalizado': return Colors.green;
      case 'cancelado': return Colors.red;
      default: return Colors.grey;
    }
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
        title: const Text('Viajes'),
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
              _editingId != null ? 'Editar Viaje' : 'Nuevo Viaje',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedRuta,
              decoration: const InputDecoration(
                labelText: 'Ruta *',
                border: OutlineInputBorder(),
              ),
              items: _rutas.map((ruta) {
                return DropdownMenuItem(
                  value: ruta.id,
                  child: Text(ruta.nombre),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedRuta = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedVehiculo,
                    decoration: const InputDecoration(
                      labelText: 'Vehículo',
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedChofer,
                    decoration: const InputDecoration(
                      labelText: 'Chofer',
                      border: OutlineInputBorder(),
                    ),
                    items: _choferes.map((chofer) {
                      return DropdownMenuItem(
                        value: chofer.id,
                        child: Text('${chofer.apellido}, ${chofer.nombre}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedChofer = value),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _horaSalidaController,
                    decoration: const InputDecoration(
                      labelText: 'Hora Salida',
                      hintText: '08:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _horaLlegadaController,
                    decoration: const InputDecoration(
                      labelText: 'Hora Llegada',
                      hintText: '10:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Programado', child: Text('Programado')),
                DropdownMenuItem(value: 'En Curso', child: Text('En Curso')),
                DropdownMenuItem(value: 'Finalizado', child: Text('Finalizado')),
                DropdownMenuItem(value: 'Cancelado', child: Text('Cancelado')),
              ],
              onChanged: (value) => setState(() => _estado = value!),
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
    if (_viajes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay viajes registrados'),
          ),
        ),
      );
    }

    return Column(
      children: _viajes.map((viaje) {
        final fecha = DateTime.parse(viaje.fecha);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getEstadoColor(viaje.estado),
              child: const Icon(Icons.route, color: Colors.white),
            ),
            title: Text(_getRutaNombre(viaje.ruta), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}'),
                Text('Vehículo: ${_getVehiculoInfo(viaje.vehiculo)}'),
                Text('Chofer: ${_getChoferInfo(viaje.chofer)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(viaje.estado).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getEstadoColor(viaje.estado)),
                  ),
                  child: Text(
                    viaje.estado,
                    style: TextStyle(
                      color: _getEstadoColor(viaje.estado),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
                  onPressed: () => _handleEdit(viaje),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                  onPressed: () => _handleDelete(viaje.id!),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

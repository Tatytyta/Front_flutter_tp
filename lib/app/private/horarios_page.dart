import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../src/lib/token_storage.dart';
import '../../src/lib/datasources/crud_service.dart';
import '../../src/config/api_constants.dart';
import '../../domain/entities/horario.dart';
import '../../domain/entities/ruta.dart';

class HorariosPage extends StatefulWidget {
  const HorariosPage({super.key});

  @override
  State<HorariosPage> createState() => _HorariosPageState();
}

class _HorariosPageState extends State<HorariosPage> {
  late final CrudService<Horario> _horarioService;
  late final CrudService<Ruta> _rutaService;
  List<Horario> _horarios = [];
  List<Ruta> _rutas = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  
  final _horaSalidaController = TextEditingController();
  final _horaLlegadaController = TextEditingController();
  final _diasSemanaController = TextEditingController();
  int? _selectedRuta;

  @override
  void initState() {
    super.initState();
    _horarioService = CrudService<Horario>(
      endpoint: ApiConstants.horariosEndpoint,
      fromJson: (json) => Horario.fromJson(json),
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
    _loadData();
  }

  @override
  void dispose() {
    _horaSalidaController.dispose();
    _horaLlegadaController.dispose();
    _diasSemanaController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final horariosResponse = await _horarioService.getAll();
      final rutasResponse = await _rutaService.getAll();
      setState(() {
        _horarios = horariosResponse.results;
        _rutas = rutasResponse.results;
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
    if (_horaSalidaController.text.isEmpty || _horaLlegadaController.text.isEmpty || _selectedRuta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruta, Hora Salida y Hora Llegada son requeridos')),
      );
      return;
    }

    final data = {
      'ruta': _selectedRuta!,
      'hora_salida': _horaSalidaController.text,
      'hora_llegada': _horaLlegadaController.text,
      'dias_semana': _diasSemanaController.text.isEmpty ? 'L,M,X,J,V' : _diasSemanaController.text,
    };

    try {
      if (_editingId != null) {
        await _horarioService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Horario actualizado')),
          );
        }
      } else {
        await _horarioService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Horario creado')),
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

  void _handleEdit(Horario horario) {
    setState(() {
      _editingId = horario.id;
      _selectedRuta = horario.ruta;
      _horaSalidaController.text = horario.horaSalida;
      _horaLlegadaController.text = horario.horaLlegada;
      _diasSemanaController.text = horario.diasSemana;
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Eliminar este horario?'),
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
        await _horarioService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Horario eliminado')),
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
      _horaSalidaController.clear();
      _horaLlegadaController.clear();
      _diasSemanaController.clear();
      _selectedRuta = null;
      _editingId = null;
      _showForm = false;
    });
  }

  String _getRutaNombre(int rutaId) {
    final ruta = _rutas.where((r) => r.id == rutaId).firstOrNull;
    return ruta?.nombre ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios'),
        backgroundColor: const Color(0xFFf39c12),
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
              _editingId != null ? 'Editar Horario' : 'Nuevo Horario',
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
                  child: TextField(
                    controller: _horaSalidaController,
                    decoration: const InputDecoration(
                      labelText: 'Hora Salida *',
                      hintText: '08:00:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _horaLlegadaController,
                    decoration: const InputDecoration(
                      labelText: 'Hora Llegada *',
                      hintText: '20:00:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _diasSemanaController,
              decoration: const InputDecoration(
                labelText: 'Días Semana *',
                hintText: 'L,M,X,J,V,S,D',
                border: OutlineInputBorder(),
              ),
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
    if (_horarios.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay horarios registrados'),
          ),
        ),
      );
    }

    return Column(
      children: _horarios.map((horario) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFf39c12),
              child: Icon(Icons.access_time, color: Colors.white),
            ),
            title: Text(_getRutaNombre(horario.ruta), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${horario.horaSalida} - ${horario.horaLlegada}'),
                Text('Días: ${horario.diasSemana}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
                  onPressed: () => _handleEdit(horario),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                  onPressed: () => _handleDelete(horario.id!),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

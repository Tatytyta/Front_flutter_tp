import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/token_storage.dart';
import '../../data/datasources/crud_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/chofer.dart';
import '../widgets/common_widgets.dart';

class ChoferesPage extends StatefulWidget {
  const ChoferesPage({super.key});

  @override
  State<ChoferesPage> createState() => _ChoferesPageState();
}

class _ChoferesPageState extends State<ChoferesPage> {
  late final CrudService<Chofer> _choferService;
  List<Chofer> _choferes = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _licenciaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _fechaContratacion;

  @override
  void initState() {
    super.initState();
    _choferService = CrudService<Chofer>(
      endpoint: ApiConstants.choferesEndpoint,
      fromJson: (json) => Chofer.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _loadChoferes();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _dniController.dispose();
    _licenciaController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadChoferes() async {
    setState(() => _loading = true);
    try {
      final response = await _choferService.getAll();
      setState(() {
        _choferes = response.results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar choferes: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_nombreController.text.isEmpty || _apellidoController.text.isEmpty ||
        _dniController.text.isEmpty || _licenciaController.text.isEmpty ||
        _fechaContratacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campos requeridos: Nombre, Apellido, DNI, Licencia, Fecha Contratación')),
      );
      return;
    }

    final data = {
      'nombre': _nombreController.text,
      'apellido': _apellidoController.text,
      'dni': _dniController.text,
      'licencia': _licenciaController.text,
      'telefono': _telefonoController.text.isEmpty ? null : _telefonoController.text,
      'email': _emailController.text.isEmpty ? null : _emailController.text,
      'fecha_contratacion': _fechaContratacion!.toIso8601String().split('T')[0],
    };

    try {
      if (_editingId != null) {
        await _choferService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Chofer actualizado correctamente')),
          );
        }
      } else {
        await _choferService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Chofer creado correctamente')),
          );
        }
      }
      _resetForm();
      _loadChoferes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }

  void _handleEdit(Chofer chofer) {
    setState(() {
      _editingId = chofer.id;
      _nombreController.text = chofer.nombre;
      _apellidoController.text = chofer.apellido;
      _dniController.text = chofer.dni;
      _licenciaController.text = chofer.licencia;
      _telefonoController.text = chofer.telefono ?? '';
      _emailController.text = chofer.email ?? '';
      _fechaContratacion = DateTime.parse(chofer.fechaContratacion);
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este chofer?'),
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
        await _choferService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Chofer eliminado')),
          );
        }
        _loadChoferes();
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
      _apellidoController.clear();
      _dniController.clear();
      _licenciaController.clear();
      _telefonoController.clear();
      _emailController.clear();
      _fechaContratacion = null;
      _editingId = null;
      _showForm = false;
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaContratacion ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _fechaContratacion = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choferes'),
        backgroundColor: const Color(0xFF16a085),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
            tooltip: _showForm ? 'Cancelar' : 'Nuevo Chofer',
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
              _editingId != null ? 'Editar Chofer' : 'Nuevo Chofer',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _apellidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido *',
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
                    controller: _dniController,
                    decoration: const InputDecoration(
                      labelText: 'DNI *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _licenciaController,
                    decoration: const InputDecoration(
                      labelText: 'Licencia *',
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
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Contratación *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _fechaContratacion != null
                      ? '${_fechaContratacion!.day}/${_fechaContratacion!.month}/${_fechaContratacion!.year}'
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    color: _fechaContratacion != null ? Colors.black : Colors.grey,
                  ),
                ),
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

  Widget _buildTable() {
    if (_choferes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No hay choferes registrados'),
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
            DataColumn(label: Text('Apellido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('DNI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Licencia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Teléfono', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Fecha Contratación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Acciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: _choferes.map((chofer) {
            final fecha = DateTime.parse(chofer.fechaContratacion);
            return DataRow(
              cells: [
                DataCell(Text(chofer.nombre)),
                DataCell(Text(chofer.apellido)),
                DataCell(Text(chofer.dni)),
                DataCell(Text(chofer.licencia)),
                DataCell(Text(chofer.telefono ?? '-')),
                DataCell(Text(chofer.email ?? '-')),
                DataCell(Text('${fecha.day}/${fecha.month}/${fecha.year}')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
                        onPressed: () => _handleEdit(chofer),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                        onPressed: () => _handleDelete(chofer.id!),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../src/lib/token_storage.dart';
import '../../src/lib/datasources/crud_service.dart';
import '../../src/config/api_constants.dart';
import '../../domain/entities/linea.dart';
import '../widgets/common_widgets.dart';

class LineasPage extends StatefulWidget {
  const LineasPage({super.key});

  @override
  State<LineasPage> createState() => _LineasPageState();
}

class _LineasPageState extends State<LineasPage> {
  late final CrudService<Linea> _lineaService;
  List<Linea> _lineas = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  
  final _numeroController = TextEditingController();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  Color _selectedColor = const Color(0xFF3498db);

  @override
  void initState() {
    super.initState();
    _lineaService = CrudService<Linea>(
      endpoint: ApiConstants.lineasEndpoint,
      fromJson: (json) => Linea.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _loadLineas();
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadLineas() async {
    setState(() => _loading = true);
    try {
      final response = await _lineaService.getAll();
      setState(() {
        _lineas = response.results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar líneas: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_numeroController.text.isEmpty || _nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número y Nombre son requeridos')),
      );
      return;
    }

    final data = {
      'numero': _numeroController.text,
      'nombre': _nombreController.text,
      'color': '#${_selectedColor.value.toRadixString(16).substring(2)}',
      'descripcion': _descripcionController.text,
    };

    try {
      if (_editingId != null) {
        await _lineaService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Línea actualizada correctamente')),
          );
        }
      } else {
        await _lineaService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Línea creada correctamente')),
          );
        }
      }
      _resetForm();
      _loadLineas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }

  void _handleEdit(Linea linea) {
    setState(() {
      _editingId = linea.id;
      _numeroController.text = linea.numero.toString();
      _nombreController.text = linea.nombre;
      _descripcionController.text = linea.descripcion ?? '';
      if (linea.color != null && linea.color!.isNotEmpty) {
        _selectedColor = Color(int.parse('FF${linea.color!.substring(1)}', radix: 16));
      }
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar esta línea?'),
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
        await _lineaService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Línea eliminada')),
          );
        }
        _loadLineas();
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
      _nombreController.clear();
      _descripcionController.clear();
      _selectedColor = const Color(0xFF3498db);
      _editingId = null;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CrudPageAppBar(
        title: 'Líneas de Transporte',
        backgroundColor: const Color(0xFF3498db),
        showForm: _showForm,
        onAddPressed: () => setState(() => _showForm = !_showForm),
        isAdminOnly: true,
      ),
      body: _loading
          ? const LoadingWidget(message: 'Cargando líneas...')
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
              _editingId != null ? 'Editar Línea' : 'Nueva Línea',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numeroController,
                    decoration: const InputDecoration(
                      labelText: 'Número *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
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
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Color'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final color = await showDialog<Color>(
                          context: context,
                          builder: (context) => _ColorPickerDialog(initialColor: _selectedColor),
                        );
                        if (color != null) {
                          setState(() => _selectedColor = color);
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
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
    if (_lineas.isEmpty) {
      return const EmptyDataWidget(
        message: 'No hay líneas registradas',
        icon: Icons.directions_bus,
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF34495e)),
          columns: const [
            DataColumn(label: Text('Número', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Nombre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Color', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Descripción', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Acciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: _lineas.map((linea) {
            return DataRow(
              cells: [
                DataCell(Text(linea.numero.toString())),
                DataCell(Text(linea.nombre)),
                DataCell(
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: linea.color != null && linea.color!.isNotEmpty ? Color(int.parse('FF${linea.color!.substring(1)}', radix: 16)) : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                DataCell(Text(linea.descripcion ?? '-')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
                        onPressed: () => _handleEdit(linea),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                        onPressed: () => _handleDelete(linea.id!),
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

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color selectedColor;

  final List<Color> colors = const [
    Color(0xFF3498db), Color(0xFF2ecc71), Color(0xFF9b59b6), Color(0xFFe67e22),
    Color(0xFFe74c3c), Color(0xFF1abc9c), Color(0xFFf39c12), Color(0xFF34495e),
    Color(0xFF16a085), Color(0xFF27ae60), Color(0xFF2980b9), Color(0xFF8e44ad),
    Color(0xFF2c3e50), Color(0xFFf1c40f), Color(0xFFe67e22), Color(0xFFc0392b),
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Color'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: colors.map((color) {
          return InkWell(
            onTap: () => setState(() => selectedColor = color),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: selectedColor == color ? Colors.black : Colors.grey,
                  width: selectedColor == color ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selectedColor),
          child: const Text('Seleccionar'),
        ),
      ],
    );
  }
}

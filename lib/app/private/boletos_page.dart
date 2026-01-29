import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../src/lib/token_storage.dart';
import '../../src/lib/datasources/crud_service.dart';
import '../../src/config/api_constants.dart';
import '../../domain/entities/boleto.dart';
import '../../domain/entities/tarjeta.dart';
import '../../domain/entities/viaje.dart';
import '../../domain/entities/user.dart';
import '../../src/auth/auth_provider.dart';

class BoletosPage extends StatefulWidget {
  const BoletosPage({super.key});

  @override
  State<BoletosPage> createState() => _BoletosPageState();
}

class _BoletosPageState extends State<BoletosPage> {
  late final CrudService<Boleto> _boletoService;
  late final CrudService<Tarjeta> _tarjetaService;
  late final CrudService<Viaje> _viajeService;
  late final CrudService<User> _usuarioService;
  List<Boleto> _boletos = [];
  List<Tarjeta> _tarjetas = [];
  List<Viaje> _viajes = [];
  List<User> _usuarios = [];
  bool _loading = true;

  // Form state
  int? _selectedTarjeta;
  int? _selectedViaje;
  String _monto = '2.50';
  final TextEditingController _montoController = TextEditingController(text: '2.50');
  int? _editingBoletoId;

  @override
  void initState() {
    super.initState();
    _boletoService = CrudService<Boleto>(
      endpoint: ApiConstants.boletosEndpoint,
      fromJson: (json) => Boleto.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _tarjetaService = CrudService<Tarjeta>(
      endpoint: ApiConstants.tarjetasEndpoint,
      fromJson: (json) => Tarjeta.fromJson(json),
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
    _usuarioService = CrudService<User>(
      endpoint: ApiConstants.usuariosEndpoint,
      fromJson: (json) => User.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _loadBoletos();
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _loadBoletos() async {
    setState(() => _loading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      final isAdmin = user?.isStaff == true || user?.isSuperuser == true;

      final boletosResponse = await _boletoService.getAll();
      final tarjetasResponse = await _tarjetaService.getAll();
      final viajesResponse = await _viajeService.getAll();

      // Solo los admins pueden listar usuarios; evita 403 para usuarios normales
      final usuariosResponse = isAdmin ? await _usuarioService.getAll() : null;

      setState(() {
        _boletos = boletosResponse.results;
        _tarjetas = tarjetasResponse.results;
        _viajes = viajesResponse.results;
        _usuarios = usuariosResponse?.results ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar boletos: $e')),
        );
      }
    }
  }

  String _getUsuarioNombre(int? tarjetaId) {
    if (tarjetaId == null) return 'Sin tarjeta';
    
    // Buscar la tarjeta
    final tarjeta = _tarjetas.firstWhere(
      (t) => t.id == tarjetaId,
      orElse: () => Tarjeta(
        usuario: 0,
        numero: '',
        tipo: '',
        saldo: '0',
        fechaEmision: '',
        fechaExpiracion: '',
        activa: false,
      ),
    );
    
    if (tarjeta.usuario == 0) return 'Tarjeta #$tarjetaId';
    
    // Buscar el usuario de la tarjeta
    final usuario = _usuarios.firstWhere(
      (u) => u.id == tarjeta.usuario,
      orElse: () => User(
        id: tarjeta.usuario,
        username: 'Usuario #${tarjeta.usuario}',
        email: '',
      ),
    );
    
    if (usuario.firstName != null || usuario.lastName != null) {
      return '${usuario.firstName ?? ''} ${usuario.lastName ?? ''}'.trim();
    }
    return usuario.username;
  }

  String _getUsuarioNombreDesdeBoleto(Boleto boleto) {
    // Usa la tarjeta para encontrar el usuario del boleto
    final tarjeta = _tarjetas.firstWhere(
      (t) => t.id == boleto.tarjeta,
      orElse: () => Tarjeta(
        usuario: 0,
        numero: '',
        tipo: '',
        saldo: '0',
        fechaEmision: '',
        fechaExpiracion: '',
        activa: false,
      ),
    );

    // Prioriza el detalle embebido si existe
    if (tarjeta.usuarioDetalle != null) {
      final detalle = tarjeta.usuarioDetalle!;
      final nombre = detalle.nombreCompleto;
      if (nombre.isNotEmpty) return nombre;
    }

    // Busca en la lista de usuarios cargada
    final usuario = _usuarios.firstWhere(
      (u) => u.id == tarjeta.usuario,
      orElse: () => User(
        id: tarjeta.usuario,
        username: 'Usuario #${tarjeta.usuario}',
        email: '',
      ),
    );

    if (usuario.firstName != null || usuario.lastName != null) {
      final nombre = '${usuario.firstName ?? ''} ${usuario.lastName ?? ''}'.trim();
      if (nombre.isNotEmpty) return nombre;
    }

    return usuario.username;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isAdmin = user?.isStaff == true || user?.isSuperuser == true;
    
    final formWidget = _buildForm();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? '🎫 Boletos' : 'Mis Boletos'),
        backgroundColor: const Color(0xFF27ae60),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBoletos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (formWidget != null) formWidget,
                    Expanded(
                      child: _boletos.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('No hay boletos registrados'),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadBoletos,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _boletos.length,
                                itemBuilder: (context, index) {
                                  final boleto = _boletos[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        child: const Icon(
                                          Icons.confirmation_number,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        'Boleto #${boleto.id}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      trailing: _buildActions(boleto, isAdmin, user?.id),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text('Tarjeta: #${boleto.tarjeta ?? '-'}'),
                                          Text('Usuario: ${_getUsuarioNombreDesdeBoleto(boleto)}'),
                                          Text('Viaje: #${boleto.viaje ?? '-'}'),
                                          Text('Monto: \$${double.tryParse(boleto.monto)?.toStringAsFixed(2) ?? boleto.monto}'),
                                          () {
                                            try {
                                              final fecha = DateTime.parse(boleto.fechaCompra);
                                              return Text(
                                                'Comprado: ${fecha.day}/${fecha.month}/${fecha.year}',
                                                style: const TextStyle(fontSize: 12),
                                              );
                                            } catch (e) {
                                              return Text(
                                                'Comprado: ${boleto.fechaCompra}',
                                                style: const TextStyle(fontSize: 12),
                                              );
                                            }
                                          }(),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

      Widget? _buildForm() {
        final authProvider = context.read<AuthProvider>();
        final user = authProvider.user;
        final isAdmin = user?.isStaff == true || user?.isSuperuser == true;

        // Solo permitir crear boletos a usuarios autenticados
        if (user == null) return null;

        // Filtrar tarjetas del usuario si no es admin
        final tarjetasVisibles = isAdmin
            ? _tarjetas
            : _tarjetas.where((t) => t.usuario == user.id).toList();

        if (tarjetasVisibles.isEmpty || _viajes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No hay tarjetas o viajes disponibles para crear boletos'),
          );
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingBoletoId != null ? 'Editar Boleto' : 'Nuevo Boleto',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Tarjeta *'),
                  value: _selectedTarjeta,
                  items: tarjetasVisibles
                      .map((t) => DropdownMenuItem(
                            value: t.id,
                            child: Text('Tarjeta #${t.numero} - Saldo: \$${t.saldo}'),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedTarjeta = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Viaje *'),
                  value: _selectedViaje,
                  items: _viajes
                      .map((v) => DropdownMenuItem(
                            value: v.id,
                            child: Text('Viaje #${v.id} - ${v.fecha}'),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() {
                    _selectedViaje = val;
                    _monto = '2.50';
                    _montoController.text = _monto;
                  }),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Monto (auto)'),
                  readOnly: true,
                  controller: _montoController,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: (_selectedTarjeta == null || _selectedViaje == null)
                      ? null
                      : _handleSubmit,
                  child: Text(_editingBoletoId != null ? 'Actualizar' : 'Guardar'),
                ),
              ],
            ),
          ),
        );
      }

      Future<void> _handleSubmit() async {
        if (_selectedTarjeta == null || _selectedViaje == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selecciona tarjeta y viaje')),
          );
          return;
        }

        final data = {
          'tarjeta': _selectedTarjeta,
          'viaje': _selectedViaje,
          'monto': _monto,
        };

        try {
          if (_editingBoletoId != null) {
            await _boletoService.update(_editingBoletoId!, data);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Boleto actualizado')),
            );
          } else {
            await _boletoService.create(data);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Boleto creado')),
            );
          }
          _selectedTarjeta = null;
          _selectedViaje = null;
          _monto = '2.50';
          _montoController.text = _monto;
          _editingBoletoId = null;
          await _loadBoletos();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear boleto: $e')),
          );
        }
      }

      Widget? _buildActions(Boleto boleto, bool isAdmin, int? currentUserId) {
        final tarjeta = boleto.tarjeta == null
            ? null
            : _tarjetas.firstWhere(
                (t) => t.id == boleto.tarjeta,
                orElse: () => Tarjeta(
                  usuario: 0,
                  numero: '',
                  tipo: '',
                  saldo: '0',
                  fechaEmision: '',
                  fechaExpiracion: '',
                  activa: false,
                ),
              );

        final belongsToUser = tarjeta != null && tarjeta.usuario == currentUserId;
        if (!isAdmin && !belongsToUser) return null;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
              onPressed: () {
                setState(() {
                  _editingBoletoId = boleto.id;
                  _selectedTarjeta = boleto.tarjeta;
                  _selectedViaje = boleto.viaje;
                  _monto = boleto.monto;
                  _montoController.text = _monto;
                });
              },
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
              onPressed: boleto.id == null
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar eliminación'),
                          content: const Text('¿Eliminar este boleto?'),
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
                          await _boletoService.delete(boleto.id!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ Boleto eliminado')),
                            );
                          }
                          _editingBoletoId = null;
                          await _loadBoletos();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al eliminar: $e')),
                            );
                          }
                        }
                      }
                    },
              tooltip: 'Eliminar',
            ),
          ],
        );
      }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/utils/token_storage.dart';
import '../../data/datasources/crud_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/tarjeta.dart';
import '../providers/auth_provider.dart';

class TarjetasPage extends StatefulWidget {
  const TarjetasPage({super.key});

  @override
  State<TarjetasPage> createState() => _TarjetasPageState();
}

class _TarjetasPageState extends State<TarjetasPage> {
  late final CrudService<Tarjeta> _tarjetaService;
  List<Tarjeta> _tarjetas = [];
  bool _loading = true;
  bool _showForm = false;
  int? _editingId;
  bool _isAdmin = false;
  
  final _numeroController = TextEditingController();
  final _saldoController = TextEditingController();
  final _fechaExpiracionController = TextEditingController();
  bool _activa = true;

  @override
  void initState() {
    super.initState();
    _tarjetaService = CrudService<Tarjeta>(
      endpoint: ApiConstants.tarjetasEndpoint,
      fromJson: (json) => Tarjeta.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _checkAdminStatus();
  }

  void _checkAdminStatus() {
    final authProvider = context.read<AuthProvider>();
    setState(() {
      _isAdmin = authProvider.user?.isStaff == true || authProvider.user?.isSuperuser == true;
    });
    _loadTarjetas();
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _saldoController.dispose();
    _fechaExpiracionController.dispose();
    super.dispose();
  }

  Future<void> _loadTarjetas() async {
    setState(() => _loading = true);
    try {
      final response = await _tarjetaService.getAll();
      final authProvider = context.read<AuthProvider>();
      
      List<Tarjeta> tarjetas = response.results;
      
      // Si no es admin, filtrar solo sus tarjetas
      if (!_isAdmin && authProvider.user?.id != null) {
        tarjetas = tarjetas.where((tarjeta) {
          return tarjeta.usuario == authProvider.user!.id;
        }).toList();
      }
      
      setState(() {
        _tarjetas = tarjetas;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar tarjetas: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_numeroController.text.isEmpty || _saldoController.text.isEmpty || _fechaExpiracionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son requeridos')),
      );
      return;
    }

    int? userId;
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe iniciar sesión primero')),
      );
      return;
    }

    if (authProvider.user != null) {
      userId = authProvider.user!.id;
      print('User ID obtenido de AuthProvider: $userId');
    } else {
      print('Usuario no disponible en AuthProvider, intentando obtener del token...');
      final token = await TokenStorage().getAccessToken();
      if (token != null) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            final normalized = base64Url.normalize(payload);
            final decoded = utf8.decode(base64Url.decode(normalized));
            final Map<String, dynamic> payloadMap = json.decode(decoded);
            print('Payload del token: $payloadMap');
            final userIdValue = payloadMap['user_id'];
            userId = userIdValue is int ? userIdValue : (userIdValue is String ? int.tryParse(userIdValue) : null);
            print('User ID del token: $userId');
          }
        } catch (e) {
          print('Error decodificando token: $e');
        }
      } else {
        print('No hay token disponible');
      }
      
      if (userId == null) {
        await authProvider.checkAuthStatus();
        if (authProvider.user != null) {
          userId = authProvider.user!.id;
          print('User ID obtenido después de checkAuthStatus: $userId');
        }
      }
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el ID de usuario. Intente cerrar sesión y volver a ingresar.'),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    final data = {
      'usuario': userId,
      'numero': _numeroController.text,
      'saldo': double.parse(_saldoController.text),
      'fecha_expiracion': _fechaExpiracionController.text,
      'activa': _activa,
    };

    try {
      if (_editingId != null) {
        await _tarjetaService.update(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Tarjeta actualizada correctamente')),
          );
        }
      } else {
        await _tarjetaService.create(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Tarjeta creada correctamente')),
          );
        }
      }
      _resetForm();
      _loadTarjetas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }

  void _handleEdit(Tarjeta tarjeta) {
    setState(() {
      _editingId = tarjeta.id;
      _numeroController.text = tarjeta.numero;
      _saldoController.text = tarjeta.saldo;
      _fechaExpiracionController.text = tarjeta.fechaExpiracion;
      _activa = tarjeta.activa;
      _showForm = true;
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar esta tarjeta?'),
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
        await _tarjetaService.delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Tarjeta eliminada')),
          );
        }
        _loadTarjetas();
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
      _saldoController.clear();
      _fechaExpiracionController.clear();
      _activa = true;
      _editingId = null;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Mis Tarjetas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8E44AD),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add_card),
            onPressed: () => setState(() => _showForm = !_showForm),
            tooltip: _showForm ? 'Cancelar' : 'Nueva Tarjeta',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTarjetas,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_showForm) ...[
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E44AD), Color(0xFF7D3C98)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8E44AD).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '💳',
                              style: TextStyle(fontSize: 48),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mis Tarjetas',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_tarjetas.length} tarjeta${_tarjetas.length != 1 ? 's' : ''} registrada${_tarjetas.length != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_showForm) _buildForm(),
                  if (!_showForm && _tarjetas.isNotEmpty) _buildList(),
                  if (!_showForm && _tarjetas.isEmpty) _buildEmptyState(),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  '💳',
                  style: TextStyle(fontSize: 80),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No tienes tarjetas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isAdmin 
                  ? 'No hay tarjetas registradas en el sistema'
                  : 'Agrega tu primera tarjeta para comenzar',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => setState(() => _showForm = true),
                icon: const Icon(Icons.add),
                label: const Text('Agregar Tarjeta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E44AD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingId != null ? '✏️ Editar Tarjeta' : '➕ Nueva Tarjeta',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _numeroController,
              decoration: InputDecoration(
                labelText: 'Número de Tarjeta *',
                hintText: 'Ej: 1234567890',
                prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF8E44AD)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8E44AD), width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _saldoController,
              decoration: InputDecoration(
                labelText: 'Saldo Inicial *',
                hintText: 'Ej: 50.00',
                prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF8E44AD)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8E44AD), width: 2),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fechaExpiracionController,
              decoration: InputDecoration(
                labelText: 'Fecha de Expiración *',
                prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF8E44AD)),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8E44AD), width: 2),
                ),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF8E44AD),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  _fechaExpiracionController.text = date.toIso8601String().split('T')[0];
                }
              },
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Tarjeta Activa',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Permite usar la tarjeta para realizar compras',
                  style: TextStyle(fontSize: 12),
                ),
                value: _activa,
                onChanged: (value) => setState(() => _activa = value ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF8E44AD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E44AD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: _tarjetas.map((tarjeta) => _buildCreditCard(tarjeta)).toList(),
    );
  }

  Widget _buildCreditCard(Tarjeta tarjeta) {
    // Colores alternados para las tarjetas
    final colors = tarjeta.activa
        ? [const Color(0xFF8E44AD), const Color(0xFF7D3C98)]
        : [const Color(0xFF94A3B8), const Color(0xFF64748B)];

    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.white, size: 32),
                          SizedBox(width: 8),
                          Text(
                            'Tarjeta de Transporte',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Color(0xFFF59E0B)),
                                SizedBox(width: 12),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Color(0xFFEF4444)),
                                SizedBox(width: 12),
                                Text('Eliminar'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _handleEdit(tarjeta);
                          } else if (value == 'delete') {
                            _handleDelete(tarjeta.id!);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Card number
                  Text(
                    _formatCardNumber(tarjeta.numero),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bottom info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Balance
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SALDO',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${double.tryParse(tarjeta.saldo)?.toStringAsFixed(2) ?? tarjeta.saldo}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Expiry
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPIRA',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatExpiryDate(tarjeta.fechaExpiracion),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tarjeta.activa
                              ? Colors.green.withOpacity(0.9)
                              : Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tarjeta.activa ? Icons.check_circle : Icons.cancel,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tarjeta.activa ? 'ACTIVA' : 'INACTIVA',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCardNumber(String number) {
    // Formato: XXXX XXXX XXXX XXXX
    if (number.length <= 4) return number;
    String formatted = '';
    for (int i = 0; i < number.length; i += 4) {
      if (i > 0) formatted += ' ';
      formatted += number.substring(i, i + 4 > number.length ? number.length : i + 4);
    }
    return formatted;
  }

  String _formatExpiryDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year.toString().substring(2)}';
    } catch (e) {
      return date;
    }
  }
}

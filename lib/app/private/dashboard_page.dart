import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../src/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Gestión de Transporte'),
        backgroundColor: const Color(0xFF2c3e50),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          final isAdmin = user?.isStaff == true || user?.isSuperuser == true;
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido, ${user?.firstName != null && user?.lastName != null ? "${user!.firstName} ${user.lastName}" : user?.username ?? ""}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2c3e50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(width: 8),
                              Text(
                                isAdmin ? 'Panel de Administración' : 'Panel de Usuario',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sistema de Gestión de Transporte',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    isAdmin ? 'Módulos de Administración' : 'Servicios Disponibles',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1200 
                          ? 4 
                          : constraints.maxWidth > 800 
                              ? 3 
                              : constraints.maxWidth > 500 
                                  ? 2 
                                  : 1;
                      
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: isAdmin ? _buildAdminModules(context) : _buildUserModules(context),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      ' Sistema de Transporte',
                      style: TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAdminModules(BuildContext context) {
    return [
      _ModuleCard(
        icon: '👤',
        title: 'Usuarios',
        color: const Color(0xFF34495e),
        onTap: () => context.go('/usuarios'),
      ),
      _ModuleCard(
        icon: '🚌',
        title: 'Líneas',
        color: const Color(0xFF3498db),
        onTap: () => context.go('/lineas'),
      ),
      _ModuleCard(
        icon: '🚏',
        title: 'Paradas',
        color: const Color(0xFF2ecc71),
        onTap: () => context.go('/paradas'),
      ),
      _ModuleCard(
        icon: '🗺️',
        title: 'Rutas',
        color: const Color(0xFF9b59b6),
        onTap: () => context.go('/rutas'),
      ),
      _ModuleCard(
        icon: '🚐',
        title: 'Vehículos',
        color: const Color(0xFFe67e22),
        onTap: () => context.go('/vehiculos'),
      ),
      _ModuleCard(
        icon: '👨‍✈️',
        title: 'Choferes',
        color: const Color(0xFF16a085),
        onTap: () => context.go('/choferes'),
      ),
      _ModuleCard(
        icon: '⏰',
        title: 'Horarios',
        color: const Color(0xFFf39c12),
        onTap: () => context.go('/horarios'),
      ),
      _ModuleCard(
        icon: '🛣️',
        title: 'Viajes',
        color: const Color(0xFFc0392b),
        onTap: () => context.go('/viajes'),
      ),
      _ModuleCard(
        icon: '🔧',
        title: 'Mantenimientos',
        color: const Color(0xFFd35400),
        onTap: () => context.go('/mantenimientos'),
      ),
      _ModuleCard(
        icon: '⚠️',
        title: 'Incidentes',
        color: const Color(0xFFc0392b),
        onTap: () => context.go('/incidentes'),
      ),
    ];
  }

  List<Widget> _buildUserModules(BuildContext context) {
    return [
      _ModuleCard(
        icon: '💳',
        title: 'Mis Tarjetas',
        color: const Color(0xFF8e44ad),
        onTap: () => context.go('/tarjetas'),
      ),
      _ModuleCard(
        icon: '🎫',
        title: 'Mis Boletos',
        color: const Color(0xFF27ae60),
        onTap: () => context.go('/boletos'),
      ),
      _ModuleCard(
        icon: '⏰',
        title: 'Horarios',
        color: const Color(0xFFf39c12),
        onTap: () => context.go('/horarios'),
      ),
      _ModuleCard(
        icon: '🗺️',
        title: 'Rutas',
        color: const Color(0xFF9b59b6),
        onTap: () => context.go('/rutas'),
      ),
    ];
  }
}

class _ModuleCard extends StatefulWidget {
  final String icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: widget.color, width: 3),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

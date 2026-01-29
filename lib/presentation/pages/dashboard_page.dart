import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Sistema de Gestión de Transporte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
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
          final isChofer = user?.isChofer == true;
          final isAsistente = user?.isAsistente == true;
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner con gradiente y diseño moderno
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF059669),
                        Color(0xFF14B8A6),
                        Color(0xFF06B6D4),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative background
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Opacity(
                          opacity: 0.1,
                          child: Text(
                            '🚌',
                            style: TextStyle(fontSize: 100),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Opacity(
                          opacity: 0.1,
                          child: Text(
                            '🚏',
                            style: TextStyle(fontSize: 100),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Logo/Icon
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    '🚍',
                                    style: TextStyle(fontSize: 48),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SISTEMA DE GESTIÓN'.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Transporte Público',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Text(
                                            '👋',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              user?.firstName != null && user?.lastName != null
                                                  ? '${user!.firstName} ${user.lastName}'
                                                  : user?.username ?? 'Usuario',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                                backdropFilter: null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rol del Sistema',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isAdmin
                                            ? '👨‍💼'
                                            : isChofer
                                                ? '🚗'
                                                : isAsistente
                                                    ? '🎫'
                                                    : '👤',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isAdmin
                                            ? 'Administrador'
                                            : isChofer
                                                ? 'Conductor'
                                                : isAsistente
                                                    ? 'Cobrador'
                                                    : 'Pasajero',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
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
                    ],
                  ),
                ),
                // Content Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Title
                      Container(
                        padding: const EdgeInsets.only(left: 16),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF0F766E),
                              width: 4,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAdmin
                                  ? '🛠️ Panel de Control'
                                  : isChofer
                                      ? '🚗 Panel del Conductor'
                                      : isAsistente
                                          ? '🎫 Panel del Cobrador'
                                          : '🎯 Servicios Disponibles',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isAdmin
                                  ? 'Administra todos los aspectos del sistema de transporte'
                                  : isChofer
                                      ? 'Gestiona tus viajes, rutas y horarios asignados'
                                      : isAsistente
                                          ? 'Gestiona boletos y asiste en tus viajes asignados'
                                          : 'Consulta horarios, rutas y gestiona tus boletos',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Modules Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 1200
                              ? 4
                              : constraints.maxWidth > 800
                                  ? 3
                                  : constraints.maxWidth > 500
                                      ? 2
                                      : 1;

                          final modules = isAdmin
                              ? _buildAdminModules(context)
                              : isChofer
                                  ? _buildChoferModules(context)
                                  : isAsistente
                                      ? _buildAsistenteModules(context)
                                      : _buildUserModules(context);

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                            children: modules,
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      // Footer
                      Center(
                        child: Text(
                          '© 2026 Sistema de Transporte Público',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAdminModules(BuildContext context) {
    return [
      _ModuleCard(
        icon: '👥',
        title: 'Usuarios',
        color: const Color(0xFF8B5CF6),
        onTap: () => context.go('/usuarios'),
      ),
      _ModuleCard(
        icon: '🚌',
        title: 'Líneas',
        color: const Color(0xFF3498DB),
        onTap: () => context.go('/lineas'),
      ),
      _ModuleCard(
        icon: '🚏',
        title: 'Paradas',
        color: const Color(0xFF2ECC71),
        onTap: () => context.go('/paradas'),
      ),
      _ModuleCard(
        icon: '🗺️',
        title: 'Rutas',
        color: const Color(0xFF9B59B6),
        onTap: () => context.go('/rutas'),
      ),
      _ModuleCard(
        icon: '🚐',
        title: 'Vehículos',
        color: const Color(0xFFE67E22),
        onTap: () => context.go('/vehiculos'),
      ),
      _ModuleCard(
        icon: '👨‍✈️',
        title: 'Choferes',
        color: const Color(0xFF16A085),
        onTap: () => context.go('/choferes'),
      ),
      _ModuleCard(
        icon: '⏰',
        title: 'Horarios',
        color: const Color(0xFFF39C12),
        onTap: () => context.go('/horarios'),
      ),
      _ModuleCard(
        icon: '🛣️',
        title: 'Viajes',
        color: const Color(0xFFC0392B),
        onTap: () => context.go('/viajes'),
      ),
      _ModuleCard(
        icon: '💳',
        title: 'Tarjetas',
        color: const Color(0xFF8E44AD),
        onTap: () => context.go('/tarjetas'),
      ),
      _ModuleCard(
        icon: '🎫',
        title: 'Boletos',
        color: const Color(0xFF27AE60),
        onTap: () => context.go('/boletos'),
      ),
      _ModuleCard(
        icon: '🔧',
        title: 'Mantenimientos',
        color: const Color(0xFFD35400),
        onTap: () => context.go('/mantenimientos'),
      ),
      _ModuleCard(
        icon: '⚠️',
        title: 'Incidentes',
        color: const Color(0xFFC0392B),
        onTap: () => context.go('/incidentes'),
      ),
    ];
  }

  List<Widget> _buildChoferModules(BuildContext context) {
    return [
      _ModuleCard(
        icon: '👤',
        title: 'Mi Perfil',
        color: const Color(0xFF059669),
        onTap: () => context.go('/perfil'),
      ),
      _ModuleCard(
        icon: '⏰',
        title: 'Mis Horarios',
        color: const Color(0xFFF59E0B),
        onTap: () => context.go('/horarios'),
      ),
      _ModuleCard(
        icon: '🗺️',
        title: 'Mis Rutas',
        color: const Color(0xFF3B82F6),
        onTap: () => context.go('/rutas'),
      ),
      _ModuleCard(
        icon: '🛣️',
        title: 'Mis Viajes',
        color: const Color(0xFF8B5CF6),
        onTap: () => context.go('/viajes'),
      ),
    ];
  }

  List<Widget> _buildAsistenteModules(BuildContext context) {
    return [
      _ModuleCard(
        icon: '�',
        title: 'Mi Perfil',
        color: const Color(0xFFF59E0B),
        onTap: () => context.go('/perfil'),
      ),
      _ModuleCard(
        icon: '🛣️',
        title: 'Mis Viajes',
        color: const Color(0xFF8B5CF6),
        onTap: () => context.go('/viajes'),
      ),
      _ModuleCard(
        icon: '🎫',
        title: 'Boletos',
        color: const Color(0xFF27AE60),
        onTap: () => context.go('/boletos'),
      ),
    ];
  }

  List<Widget> _buildUserModules(BuildContext context) {
    return [
      _ModuleCard(
        icon: '💳',
        title: 'Mis Tarjetas',
        color: const Color(0xFF8E44AD),
        onTap: () => context.go('/tarjetas'),
      ),
      _ModuleCard(
        icon: '🎫',
        title: 'Mis Boletos',
        color: const Color(0xFF27AE60),
        onTap: () => context.go('/boletos'),
      ),
      _ModuleCard(
        icon: '⏰',
        title: 'Horarios',
        color: const Color(0xFFF39C12),
        subtitle: 'Solo lectura',
        onTap: () => context.go('/horarios'),
      ),
      _ModuleCard(
        icon: '🗺️',
        title: 'Rutas',
        color: const Color(0xFF9B59B6),
        subtitle: 'Solo lectura',
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
  final String? subtitle;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.subtitle,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Card(
          elevation: _isHovered ? 12 : 3,
          shadowColor: widget.color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: widget.color.withOpacity(0.1),
            highlightColor: widget.color.withOpacity(0.05),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered ? widget.color : Colors.transparent,
                  width: 2,
                ),
                gradient: _isHovered
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.05),
                          Colors.white,
                        ],
                      )
                    : null,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with animation
                  AnimatedScale(
                    scale: _isHovered ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      widget.icon,
                      style: const TextStyle(fontSize: 52),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _isHovered ? widget.color : const Color(0xFF1E293B),
                      height: 1.2,
                    ),
                  ),
                  // Subtitle if exists
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  // Arrow indicator on hover
                  AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Ir al módulo →',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

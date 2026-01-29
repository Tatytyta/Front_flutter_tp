import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'Sistema de Transporte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => context.go('/register'),
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Registro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 500),
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
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative Background
                  Positioned(
                    top: 20,
                    left: 40,
                    child: Opacity(
                      opacity: 0.1,
                      child: Text('🚌', style: TextStyle(fontSize: 100)),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 40,
                    child: Opacity(
                      opacity: 0.1,
                      child: Text('🚏', style: TextStyle(fontSize: 100)),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 80,
                    child: Opacity(
                      opacity: 0.1,
                      child: Text('🗺️', style: TextStyle(fontSize: 70)),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: 80,
                    child: Opacity(
                      opacity: 0.1,
                      child: Text('🚍', style: TextStyle(fontSize: 70)),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
                    child: Column(
                      children: [
                        const Text(
                          '🚍',
                          style: TextStyle(fontSize: 100),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Sistema de Gestión',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black26,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Transporte Público',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black26,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 4,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Plataforma integral para la administración y control de servicios de transporte urbano',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildHeroButton(
                              context: context,
                              label: '🔑  Acceder al Sistema',
                              onPressed: () => context.go('/login'),
                              isPrimary: true,
                            ),
                            _buildHeroButton(
                              context: context,
                              label: '📝  Crear Cuenta',
                              onPressed: () => context.go('/register'),
                              isPrimary: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Info Cards
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return Row(
                          children: [
                            Expanded(child: _buildInfoCard(
                              icon: '🚌',
                              title: 'Gestión de Flota',
                              description: 'Administra vehículos, rutas y horarios',
                              colors: [Color(0xFFDCEBFE), Color(0xFFBFDBFE)],
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _buildInfoCard(
                              icon: '👥',
                              title: 'Control de Personal',
                              description: 'Gestiona conductores y cobradores',
                              colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _buildInfoCard(
                              icon: '🎫',
                              title: 'Sistema de Boletos',
                              description: 'Venta y control de pasajes',
                              colors: [Color(0xFFFED7AA), Color(0xFFFDBA74)],
                            )),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildInfoCard(
                            icon: '🚌',
                            title: 'Gestión de Flota',
                            description: 'Administra vehículos, rutas y horarios',
                            colors: [Color(0xFFDCEBFE), Color(0xFFBFDBFE)],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: '👥',
                            title: 'Control de Personal',
                            description: 'Gestiona conductores y cobradores',
                            colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: '🎫',
                            title: 'Sistema de Boletos',
                            description: 'Venta y control de pasajes',
                            colors: [Color(0xFFFED7AA), Color(0xFFFDBA74)],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  Text(
                    '© 2026 Sistema de Transporte Público',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.transparent,
        foregroundColor: isPrimary ? const Color(0xFF0F766E) : Colors.white,
        side: isPrimary ? null : const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: isPrimary ? 8 : 0,
        shadowColor: Colors.black38,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String icon,
    required String title,
    required String description,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

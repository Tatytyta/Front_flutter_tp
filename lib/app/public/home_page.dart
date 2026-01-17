import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Transporte'),
        backgroundColor: const Color(0xFF2c3e50),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => context.go('/register'),
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Registro', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.directions_bus,
                  size: 100,
                  color: Color(0xFF3498db),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Bienvenido al Sistema de Transporte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gestiona tu sistema de transporte de manera eficiente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 48),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.login),
                      label: const Text('Iniciar Sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498db),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/register'),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Registrarse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ecc71),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Características',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildFeature('✓ Gestión de usuarios'),
                        _buildFeature('✓ Autenticación segura'),
                        _buildFeature('✓ Panel de control intuitivo'),
                        _buildFeature('✓ Gestión de líneas y rutas'),
                        _buildFeature('✓ Control de vehículos y choferes'),
                        _buildFeature('✓ Sistema de tarjetas y boletos'),
                        _buildFeature('✓ Registro de mantenimientos'),
                        _buildFeature('✓ Control de incidentes'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '© 2026 Sistema de Transporte',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF2ecc71),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

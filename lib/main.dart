import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'src/lib/token_storage.dart';
import 'src/auth/auth_remote_data_source.dart';
import 'src/auth/auth_repository_impl.dart';
import 'src/auth/auth_provider.dart';
import 'app/public/login_page.dart';
import 'app/public/register_page.dart';
import 'app/private/dashboard_page.dart';
import 'app/private/lineas_page.dart';
import 'app/private/paradas_page.dart';
import 'app/private/rutas_page.dart';
import 'app/private/vehiculos_page.dart';
import 'app/private/choferes_page.dart';
import 'app/private/horarios_page.dart';
import 'app/private/viajes_page.dart';
import 'app/private/mantenimientos_page.dart';
import 'app/private/incidentes_page.dart';
import 'app/private/tarjetas_page.dart';
import 'app/private/boletos_page.dart';
import 'app/public/home_page.dart';
import 'app/private/usuarios_page.dart';
import 'app/private/perfil_page.dart';
import 'app/require_admin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = TokenStorage();
    final authRemoteDataSource = AuthRemoteDataSource(
      client: http.Client(),
    );
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      tokenStorage: tokenStorage,
    );

    final authProvider = AuthProvider(authRepository: authRepository);
    
    authProvider.checkAuthStatus();

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) async {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';
        final isRegistering = state.matchedLocation == '/register';
        final isHome = state.matchedLocation == '/';

        // Si está autenticado y va a login/register/home, redirigir a dashboard
        if (isAuthenticated && (isLoggingIn || isRegistering || isHome)) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const RequireAuth(
            child: DashboardPage(),
          ),
        ),
        GoRoute(
          path: '/perfil',
          builder: (context, state) => const RequireAuth(
            child: PerfilPage(),
          ),
        ),
        // Rutas SOLO para administradores
        GoRoute(
          path: '/usuarios',
          builder: (context, state) => const RequireAdmin(
            child: UsuariosPage(),
          ),
        ),
        GoRoute(
          path: '/lineas',
          builder: (context, state) => const RequireAdmin(
            child: LineasPage(),
          ),
        ),
        GoRoute(
          path: '/paradas',
          builder: (context, state) => const RequireAdmin(
            child: ParadasPage(),
          ),
        ),
        GoRoute(
          path: '/rutas',
          builder: (context, state) => const RequireAuth(
            child: RutasPage(),
          ),
        ),
        GoRoute(
          path: '/vehiculos',
          builder: (context, state) => const RequireAdmin(
            child: VehiculosPage(),
          ),
        ),
        GoRoute(
          path: '/choferes',
          builder: (context, state) => const RequireAdmin(
            child: ChoferesPage(),
          ),
        ),
        GoRoute(
          path: '/horarios',
          builder: (context, state) => const RequireAuth(
            child: HorariosPage(),
          ),
        ),
        GoRoute(
          path: '/viajes',
          builder: (context, state) => const RequireAdmin(
            child: ViajesPage(),
          ),
        ),
        GoRoute(
          path: '/mantenimientos',
          builder: (context, state) => const RequireAdmin(
            child: MantenimientosPage(),
          ),
        ),
        GoRoute(
          path: '/incidentes',
          builder: (context, state) => const RequireAdmin(
            child: IncidentesPage(),
          ),
        ),
        // Rutas para usuarios autenticados (no requieren admin)
        GoRoute(
          path: '/tarjetas',
          builder: (context, state) => const RequireAuth(
            child: TarjetasPage(),
          ),
        ),
        GoRoute(
          path: '/boletos',
          builder: (context, state) => const RequireAuth(
            child: BoletosPage(),
          ),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => authProvider,
        ),
      ],
      child: MaterialApp.router(
        title: 'Sistema de Transporte',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}

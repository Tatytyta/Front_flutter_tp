# Front Flutter - Sistema de Transporte

Aplicación móvil Flutter para el sistema de gestión de transporte público.

## Requisitos

### Software necesario
- **Flutter SDK**: ^3.9.2 o superior
- **Dart SDK**: Incluido con Flutter
- **Android Studio** o **VS Code** con extensiones de Flutter/Dart
- **Git**

### Para desarrollo Android
- Android SDK (API 21 o superior)
- Emulador Android o dispositivo físico

### Para desarrollo iOS (solo en macOS)
- Xcode 12 o superior
- CocoaPods
- Simulador iOS o dispositivo físico

### Para desarrollo Windows
- Visual Studio 2022 con desarrollo de escritorio C++

## Instalación

### 1. Verificar instalación de Flutter

```bash
flutter doctor
```

Este comando te mostrará si falta algún componente. Instala los componentes faltantes según las indicaciones.

### 2. Clonar el repositorio

```bash
git clone <https://github.com/Tatytyta/Front_flutter_tp>
cd front_flutter/front_flutter/front_flutter
```

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Verificar dispositivos disponibles

```bash
flutter devices
```

## Configuración

### Variables de entorno / Configuración de API

La URL de la API se configura en el archivo:
```
lib/src/config/api_constants.dart
```

**Configuración actual:**
```dart
static const String baseUrl = 'https://herrera-transporte-api.desarrollo-software.xyz';
```

Para cambiar la URL de la API:

1. Abre `lib/src/config/api_constants.dart`
2. Modifica la constante `baseUrl`:
```dart
static const String baseUrl = 'http://localhost:8000';
```

### Endpoints disponibles

La aplicación se conecta a los siguientes endpoints:

- **Autenticación:**
  - Login: `/api/token/`
  - Registro: `/api/usuarios/register/`
  - Usuario actual: `/api/usuarios/me/`

- **Gestión (requiere autenticación):**
  - Usuarios: `/api/usuarios/`
  - Líneas: `/api/lineas/`
  - Paradas: `/api/paradas/`
  - Rutas: `/api/rutas/`
  - Vehículos: `/api/vehiculos/`
  - Choferes: `/api/choferes/`
  - Horarios: `/api/horarios/`
  - Viajes: `/api/viajes/`
  - Tarjetas: `/api/tarjetas/`
  - Boletos: `/api/boletos/`
  - Mantenimientos: `/api/mantenimientos/`
  - Incidentes: `/api/incidentes/`

## Comandos principales

### Durante la ejecución

- `r` - Hot reload (recarga rápida)
- `R` - Hot restart (reinicio completo)
- `h` - Mostrar comandos disponibles
- `d` - Detach (dejar la app corriendo en segundo plano)
- `q` - Quit (cerrar la aplicación)

### Compilar la aplicación

```bash
# Android APK (debug)
flutter build apk --debug

# Android APK (release)
flutter build apk --release

# Android App Bundle (para Google Play)
flutter build appbundle


### Limpiar el proyecto

```bash
flutter clean
flutter pub get
```

### Actualizar dependencias

```bash
flutter pub upgrade
```


### Analizar el código

```bash
flutter analyze
```

### Ver versión de Flutter

```bash
flutter --version
```

## Credenciales de prueba

### Usuario Administrador
Para acceder a todas las funcionalidades administrativas:
- **Email/Usuario:** (damian)
- **Contraseña:** (sa.1)

### Usuario Regular
Para funcionalidades de usuario normal:
- **Email/Usuario:** (damian12)
- **Contraseña:** (sa.1)

**Nota:** Las credenciales específicas deben ser proporcionadas por el equipo de backend.

## Cómo conectarse a la API

### 1. Verificar que la API esté corriendo

Asegúrate de que el backend esté en ejecución y accesible en la URL configurada.

### 2. Configurar la URL de la API

Edita `lib/src/config/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://herrera-transporte-api.desarrollo-software.xyz';
}
```

### 3. Permisos de red

#### Android
El archivo `android/app/src/main/AndroidManifest.xml` ya incluye los permisos necesarios:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

#### iOS
El archivo `ios/Runner/Info.plist` debe incluir:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 4. Probar la conexión

1. Ejecuta la aplicación
2. Navega a la pantalla de login
3. Intenta iniciar sesión con las credenciales proporcionadas
4. Si hay errores de conexión, verifica:
   - URL de la API configurada correctamente
   - Backend está corriendo
   - Firewall/antivirus no está bloqueando la conexión
   - Para emulador Android: usar `10.0.2.2` en lugar de `localhost`

## Funcionalidades

### Para todos los usuarios:
- Registro de cuenta
- Inicio de sesión
- Visualización de dashboard personal
- Ver tarjetas y boletos

### Para administradores:
- Gestión de usuarios
- Gestión de líneas de transporte
- Gestión de paradas
- Gestión de rutas
- Gestión de vehículos
- Gestión de choferes
- Gestión de horarios
- Gestión de viajes
- Gestión de mantenimientos
- Gestión de incidentes
- Gestión de tarjetas
- Gestión de boletos

## 5 Estructura del proyecto

```
lib/
├── app/
│   ├── public/
│   │   ├── home_page.dart
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── private/
│   │   ├── dashboard_page.dart
│   │   ├── usuarios_page.dart
│   │   ├── lineas_page.dart
│   │   ├── paradas_page.dart
│   │   ├── rutas_page.dart
│   │   ├── vehiculos_page.dart
│   │   ├── choferes_page.dart
│   │   ├── horarios_page.dart
│   │   ├── viajes_page.dart
│   │   ├── mantenimientos_page.dart
│   │   ├── incidentes_page.dart
│   │   ├── tarjetas_page.dart
│   │   └── boletos_page.dart
│   └── require_admin.dart
├── src/
│   ├── config/
│   │   └── api_constants.dart
│   ├── lib/
│   │   └── token_storage.dart
│   └── auth/
│       ├── auth_remote_data_source.dart
│       ├── auth_repository_impl.dart
│       └── auth_provider.dart
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
└── main.dart
```

## Solución de problemas comunes

### Error: "No se puede conectar a la API"
- Verifica que la URL de la API sea correcta
- Asegúrate de que el backend esté corriendo
- Para emulador Android, usa `10.0.2.2` en lugar de `localhost`

### Error: "pubspec.yaml not found"
- Asegúrate de estar en el directorio correcto: `front_flutter/front_flutter/front_flutter/`

### Error de dependencias
```bash
flutter clean
flutter pub get
```

### Problemas de compilación Android
```bash
cd android
./gradlew clean
cd ..
flutter run
```

## Dependencias principales

- **http**: ^1.1.0
- **provider**: ^6.1.1
- **shared_preferences**: ^2.2.2
- **go_router**: ^12.1.3
- **cupertino_icons**: ^1.0.8
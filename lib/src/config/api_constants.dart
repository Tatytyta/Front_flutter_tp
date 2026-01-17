class ApiConstants {
  static const String baseUrl = 'https://herrera-transporte-api.desarrollo-software.xyz';
  
  static const String loginEndpoint = '/api/token/';
  static const String registerEndpoint = '/api/usuarios/register/';
  static const String userEndpoint = '/api/usuarios/me/';
  static const String usuariosEndpoint = '/api/usuarios/';
  
  static const String lineasEndpoint = '/api/lineas/';
  static const String paradasEndpoint = '/api/paradas/';
  static const String rutasEndpoint = '/api/rutas/';
  static const String vehiculosEndpoint = '/api/vehiculos/';
  static const String choferesEndpoint = '/api/choferes/';
  static const String horariosEndpoint = '/api/horarios/';
  static const String viajesEndpoint = '/api/viajes/';
  
  static const String tarjetasEndpoint = '/api/tarjetas/';
  static const String boletosEndpoint = '/api/boletos/';
  static const String mantenimientosEndpoint = '/api/mantenimientos/';
  static const String incidentesEndpoint = '/api/incidentes/';
  static const String rutaParadasEndpoint = '/api/ruta-paradas/';
  
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

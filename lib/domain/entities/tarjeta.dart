class UsuarioDetalle {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;

  const UsuarioDetalle({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
  });

  String get nombreCompleto {
    final nombre = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return nombre.isNotEmpty ? nombre : username;
  }

  factory UsuarioDetalle.fromJson(Map<String, dynamic> json) {
    return UsuarioDetalle(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );
  }
}

class Tarjeta {
  final int? id;
  final int usuario;
  final UsuarioDetalle? usuarioDetalle;
  final String numero;
  final String tipo;
  final String saldo;
  final String fechaEmision;
  final String fechaExpiracion;
  final bool activa;

  Tarjeta({
    this.id,
    required this.usuario,
    this.usuarioDetalle,
    required this.numero,
    required this.tipo,
    required this.saldo,
    required this.fechaEmision,
    required this.fechaExpiracion,
    required this.activa,
  });

  factory Tarjeta.fromJson(Map<String, dynamic> json) {
    return Tarjeta(
      id: json['id'] as int?,
        usuario: json['usuario'] is int
          ? json['usuario'] as int
          : int.tryParse(json['usuario'].toString()) ?? 0,
        usuarioDetalle: json['usuario_detalle'] is Map<String, dynamic>
          ? UsuarioDetalle.fromJson(json['usuario_detalle'] as Map<String, dynamic>)
          : null,
      numero: json['numero'] as String,
      tipo: json['tipo'] as String,
      saldo: json['saldo'].toString(),
      fechaEmision: json['fecha_emision'] as String,
      fechaExpiracion: json['fecha_expiracion'] as String,
      activa: json['activa'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'usuario': usuario,
      'numero': numero,
      'tipo': tipo,
      'saldo': saldo,
      'fecha_emision': fechaEmision,
      'fecha_expiracion': fechaExpiracion,
      'activa': activa,
    };
  }
}

class Tarjeta {
  final int? id;
  final int usuario;
  final String numero;
  final String tipo;
  final String saldo;
  final String fechaEmision;
  final String fechaExpiracion;
  final bool activa;

  Tarjeta({
    this.id,
    required this.usuario,
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
      usuario: json['usuario'] as int,
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

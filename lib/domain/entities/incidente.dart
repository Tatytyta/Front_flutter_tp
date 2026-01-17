class Incidente {
  final int? id;
  final int? viaje;
  final String fecha;
  final String descripcion;
  final String gravedad;
  final bool resuelto;

  Incidente({
    this.id,
    this.viaje,
    required this.fecha,
    required this.descripcion,
    required this.gravedad,
    required this.resuelto,
  });

  factory Incidente.fromJson(Map<String, dynamic> json) => Incidente(
        id: json['id'] as int?,
        viaje: json['viaje'] as int?,
        fecha: json['fecha'] as String,
        descripcion: json['descripcion'] as String,
        gravedad: json['gravedad'] as String,
        resuelto: json['resuelto'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (viaje != null) 'viaje': viaje,
        'fecha': fecha,
        'descripcion': descripcion,
        'gravedad': gravedad,
        'resuelto': resuelto,
      };
}

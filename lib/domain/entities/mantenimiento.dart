class Mantenimiento {
  final int? id;
  final int vehiculo;
  final String tipo;
  final String fecha;
  final String descripcion;
  final String? costo;

  Mantenimiento({
    this.id,
    required this.vehiculo,
    required this.tipo,
    required this.fecha,
    required this.descripcion,
    this.costo,
  });

  factory Mantenimiento.fromJson(Map<String, dynamic> json) => Mantenimiento(
        id: json['id'] as int?,
        vehiculo: json['vehiculo'] as int,
        tipo: json['tipo'] as String,
        fecha: json['fecha'] as String,
        descripcion: json['descripcion'] as String,
        costo: json['costo']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'vehiculo': vehiculo,
        'tipo': tipo,
        'fecha': fecha,
        'descripcion': descripcion,
        if (costo != null) 'costo': costo,
      };
}

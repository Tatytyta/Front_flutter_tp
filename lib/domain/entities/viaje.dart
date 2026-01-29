class Viaje {
  final int? id;
  final String ruta;
  final int vehiculo;
  final int chofer;
  final String fecha;
  final String? horaSalidaReal;
  final String? horaLlegadaReal;
  final String estado;

  Viaje({
    this.id,
    required this.ruta,
    required this.vehiculo,
    required this.chofer,
    required this.fecha,
    this.horaSalidaReal,
    this.horaLlegadaReal,
    required this.estado,
  });

  factory Viaje.fromJson(Map<String, dynamic> json) => Viaje(
        id: json['id'] as int?,
        ruta: json['ruta']?.toString() ?? '',
        vehiculo: json['vehiculo'] as int,
        chofer: json['chofer'] as int,
        fecha: json['fecha'] as String,
        horaSalidaReal: json['hora_salida_real'] as String?,
        horaLlegadaReal: json['hora_llegada_real'] as String?,
        estado: json['estado'] as String,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'ruta': ruta,
        'vehiculo': vehiculo,
        'chofer': chofer,
        'fecha': fecha,
        if (horaSalidaReal != null) 'hora_salida_real': horaSalidaReal,
        if (horaLlegadaReal != null) 'hora_llegada_real': horaLlegadaReal,
        'estado': estado,
      };
}

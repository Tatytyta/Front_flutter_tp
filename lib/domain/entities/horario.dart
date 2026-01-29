class Horario {
  final int? id;
  final String ruta;
  final String horaSalida;
  final String horaLlegada;
  final String diasSemana;

  Horario({
    this.id,
    required this.ruta,
    required this.horaSalida,
    required this.horaLlegada,
    required this.diasSemana,
  });

  factory Horario.fromJson(Map<String, dynamic> json) => Horario(
        id: json['id'] as int?,
        ruta: json['ruta']?.toString() ?? '',
        horaSalida: json['hora_salida'] as String,
        horaLlegada: json['hora_llegada'] as String,
        diasSemana: json['dias_semana'] as String,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'ruta': ruta,
        'hora_salida': horaSalida,
        'hora_llegada': horaLlegada,
        'dias_semana': diasSemana,
      };
}

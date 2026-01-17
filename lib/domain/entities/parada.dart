class Parada {
  final int? id;
  final String nombre;
  final String direccion;
  final double? latitud;
  final double? longitud;

  Parada({
    this.id,
    required this.nombre,
    required this.direccion,
    this.latitud,
    this.longitud,
  });

  factory Parada.fromJson(Map<String, dynamic> json) {
    return Parada(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      latitud: json['latitud'] != null ? (json['latitud'] as num).toDouble() : null,
      longitud: json['longitud'] != null ? (json['longitud'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'direccion': direccion,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
    };
  }
}

class Parada {
  final String? id;
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
      id: json['id']?.toString(),
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      latitud: json['latitud'] != null
          ? double.tryParse(json['latitud'].toString())
          : null,
      longitud: json['longitud'] != null
          ? double.tryParse(json['longitud'].toString())
          : null,
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

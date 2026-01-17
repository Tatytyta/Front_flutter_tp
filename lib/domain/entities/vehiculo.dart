class Vehiculo {
  final int? id;
  final String patente;
  final String? marca;
  final String? modelo;
  final int? anio;
  final int capacidad;
  final int? totalViajes;

  Vehiculo({
    this.id,
    required this.patente,
    this.marca,
    this.modelo,
    this.anio,
    required this.capacidad,
    this.totalViajes,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'] as int?,
      patente: json['patente'] as String,
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      anio: json['anio'] as int?,
      capacidad: json['capacidad'] as int,
      totalViajes: json['total_viajes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patente': patente,
      if (marca != null) 'marca': marca,
      if (modelo != null) 'modelo': modelo,
      if (anio != null) 'anio': anio,
      'capacidad': capacidad,
    };
  }
}

class Ruta {
  final String? id;
  final String linea;
  final int? lineaNumero;
  final String? lineaNombre;
  final String nombre;
  final String? descripcion;

  Ruta({
    this.id,
    required this.linea,
    this.lineaNumero,
    this.lineaNombre,
    required this.nombre,
    this.descripcion,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) => Ruta(
        id: json['id']?.toString(),
        linea: json['linea']?.toString() ?? '',
        lineaNumero: json['linea_detalle'] != null ? json['linea_detalle']['numero'] as int? : int.tryParse(json['linea']?.toString() ?? ''),
        lineaNombre: json['linea_detalle'] != null ? json['linea_detalle']['nombre'] as String? : null,
        nombre: json['nombre'] as String,
        descripcion: json['descripcion'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'linea': linea,
        if (lineaNumero != null) 'linea_numero': lineaNumero,
        'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
      };
}

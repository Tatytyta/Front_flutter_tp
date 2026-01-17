class Ruta {
  final int? id;
  final int linea;
  final String nombre;
  final String? descripcion;

  Ruta({
    this.id,
    required this.linea,
    required this.nombre,
    this.descripcion,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) => Ruta(
        id: json['id'] as int?,
        linea: json['linea'] as int,
        nombre: json['nombre'] as String,
        descripcion: json['descripcion'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'linea': linea,
        'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
      };
}

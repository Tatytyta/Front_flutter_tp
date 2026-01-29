class Linea {
  final String? id;
  final int numero;
  final String nombre;
  final String? color;
  final String? descripcion;
  final int? totalRutas;

  Linea({
    this.id,
    required this.numero,
    required this.nombre,
    this.color,
    this.descripcion,
    this.totalRutas,
  });

  factory Linea.fromJson(Map<String, dynamic> json) {
    return Linea(
        id: json['id']?.toString(),
        numero: json['numero'] is int
          ? json['numero'] as int
          : int.tryParse(json['numero'].toString()) ?? 0,
      nombre: json['nombre'] as String,
      color: json['color'] as String?,
      descripcion: json['descripcion'] as String?,
      totalRutas: json['total_rutas'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'numero': numero,
      'nombre': nombre,
      if (color != null) 'color': color,
      if (descripcion != null && descripcion!.isNotEmpty) 'descripcion': descripcion,
    };
  }
}

class Chofer {
  final int? id;
  final String nombre;
  final String apellido;
  final String dni;
  final String licencia;
  final String? telefono;
  final String? email;
  final String fechaContratacion;

  Chofer({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.licencia,
    this.telefono,
    this.email,
    required this.fechaContratacion,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Chofer.fromJson(Map<String, dynamic> json) {
    return Chofer(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      dni: json['dni'] as String,
      licencia: json['licencia'] as String,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      fechaContratacion: json['fecha_contratacion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'dni': dni,
      'licencia': licencia,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      'fecha_contratacion': fechaContratacion,
    };
  }
}

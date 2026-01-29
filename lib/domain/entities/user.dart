class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isStaff;
  final bool isSuperuser;
  final bool isChofer;
  final bool isAsistente;
  final int? choferId;
  final String? choferDni;
  final String? choferLicencia;
  final String? choferTelefono;
  final String? choferFechaContratacion;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.isStaff = false,
    this.isSuperuser = false,
    this.isChofer = false,
    this.isAsistente = false,
    this.choferId,
    this.choferDni,
    this.choferLicencia,
    this.choferTelefono,
    this.choferFechaContratacion,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      isStaff: json['is_staff'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      isChofer: json['is_chofer'] as bool? ?? false,
      isAsistente: json['is_asistente'] as bool? ?? false,
      choferId: json['chofer_id'] as int?,
      choferDni: json['chofer_dni'] as String?,
      choferLicencia: json['chofer_licencia'] as String?,
      choferTelefono: json['chofer_telefono'] as String?,
      choferFechaContratacion: json['chofer_fecha_contratacion'] as String?,
    );
  }
}

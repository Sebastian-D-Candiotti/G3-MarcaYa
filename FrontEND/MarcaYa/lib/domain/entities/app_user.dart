/// User role enum for the domain layer.
enum UserRole { employee, admin, empresa }

/// Core domain entity representing an authenticated user.
class AppUser {
  const AppUser({
    required this.id,
    required this.nombre,
    required this.correo,
    this.password = '',
    this.claveHash,
    required this.rol,
    this.estado = 'activo',
    this.fechaRegistro,
    this.employeeId,
    this.empresaId,
    this.nombreEmpresa,
  });

  final String id;
  final String nombre;
  final String correo;
  final String password;
  final String? claveHash;
  final UserRole rol;
  final String estado;
  final DateTime? fechaRegistro;
  final String? employeeId;
  final String? empresaId;
  final String? nombreEmpresa;

  // ── Backward-compatible getters ──────────────────────────
  String get name => nombre;
  String get email => correo;
  UserRole get role => rol;
  String? get companyId => empresaId;

  /// Parse from backend JSON response.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      claveHash: json['clave_hash'] as String?,
      rol: _parseRole(json['rol'] as String? ?? 'empleado'),
      estado: json['estado'] as String? ?? 'activo',
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.tryParse(json['fechaRegistro'] as String)
          : null,
      empresaId: json['empresa_id']?.toString(),
      nombreEmpresa: json['nombre_empresa'] as String?,
    );
  }

  /// Serialize editable fields for backend.
  Map<String, dynamic> toJson() => {'nombre': nombre, 'correo': correo};

  static UserRole _parseRole(String rol) {
    switch (rol) {
      case 'admin':
        return UserRole.admin;
      case 'empresa':
        return UserRole.empresa;
      default:
        return UserRole.employee;
    }
  }
}

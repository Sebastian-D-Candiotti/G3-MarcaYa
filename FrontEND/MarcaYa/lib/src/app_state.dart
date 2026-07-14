import 'dart:math';

import 'package:flutter/foundation.dart';

enum UserRole { employee, admin, empresa }

enum AttendanceType { entry, exit }

enum RequestStatus { pending, accepted, rejected }

enum GpsScenario { insideZone, outsideZone, unavailable }

class AppUser {
  const AppUser({
    required this.id,
    required this.nombre,
    required this.correo,
    this.password = '',
    this.claveHash,
    required this.rol,
    this.estado = 'activo',
    this.otpVerificado = false,
    this.fechaRegistro,
    this.employeeId,
    this.empresaId,
    this.nombreEmpresa,
    this.descripcion,
    this.telefono,
    this.direccion,
    this.fotoUrl,
    this.apellido,
    this.promedioEstrellas,
    this.comentarios,
    this.ruc,
    this.dni,
    this.deviceId,
  });

  final String id;
  final String nombre;
  final String correo;
  final String password; // plaintext para modo mock
  final String? claveHash; // bcrypt hash desde backend real
  final UserRole rol;
  final String estado; // 'activo' | 'inactivo'
  final bool otpVerificado;
  final DateTime? fechaRegistro;
  final String? employeeId; // id del empleado asociado (backend: employee_id)
  final String? empresaId; // id de la empresa (compañía del empleado)
  final String? nombreEmpresa; // nombre de empresa (solo para rol empresa)
  final String? descripcion;
  final String? telefono;
  final String? direccion;
  final String? fotoUrl;
  final String? apellido;
  final String? ruc;
  final String? dni;
  final String? deviceId;
  final double? promedioEstrellas;
  final List<dynamic>? comentarios;


  // ── Getters retrocompatibles ───────────────────────────────
  String get name => nombre;
  String get email => correo;
  UserRole get role => rol;
  String? get companyId => empresaId;

  /// Parsea respuesta JSON del backend real.
  ///
  /// Acepta tanto snake_case (auth perfil) como camelCase (serializers).
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      rol: _parseRole(json['rol'] as String? ?? 'empleado'),
      estado: json['estado'] as String? ?? 'activo',
      otpVerificado: json['otp_verificado'] as bool? ?? json['otpVerificado'] as bool? ?? false,
      fechaRegistro: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : json['fechaRegistro'] != null
              ? DateTime.tryParse(json['fechaRegistro'] as String)
              : null,
      employeeId: json['employee_id']?.toString(),
      empresaId: json['empresa_id']?.toString(),
      nombreEmpresa: json['nombre_empresa'] as String?,
      apellido: json['apellido'] as String?,
      descripcion: json['descripcion'] as String?,
      telefono: json['telefono'] as String?,
      fotoUrl: json['foto_url'] as String?,
      direccion: json['direccion'] as String?,
      ruc: json['ruc'] as String?,
      dni: json['dni'] as String?,
      deviceId: json['device_id']?.toString() ?? json['deviceId']?.toString(),
      promedioEstrellas: json['promedio_estrellas'] != null
          ? (json['promedio_estrellas'] as num).toDouble()
          : null,
      comentarios: json['comentarios'] as List<dynamic>?,
    );
  }

  /// Serializa para enviar al backend (solo campos editables)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
    };
  }

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

class WorkStop {
  const WorkStop({
    required this.id,
    required this.companyId,
    required this.name,
    required this.siteName,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.active,
    required this.employeeIds,
  });

  final String id;
  final String companyId;
  final String name;
  final String siteName;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool active;
  final List<String> employeeIds;

  WorkStop copyWith({
    String? name,
    String? siteName,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? active,
    List<String>? employeeIds,
  }) {
    return WorkStop(
      id: id,
      companyId: companyId,
      name: name ?? this.name,
      siteName: siteName ?? this.siteName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      active: active ?? this.active,
      employeeIds: employeeIds ?? this.employeeIds,
    );
  }
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.stopId,
    required this.timestamp,
    required this.type,
    required this.validGps,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String employeeId;
  final String stopId;
  final DateTime timestamp;
  final AttendanceType type;
  final bool validGps;
  final double latitude;
  final double longitude;
}

class JoinRequest {
  const JoinRequest({
    required this.id,
    required this.employeeId,
    required this.companyId,
    required this.siteName,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String employeeId;
  final String companyId;
  final String siteName;
  final DateTime createdAt;
  final RequestStatus status;

  JoinRequest copyWith({RequestStatus? status}) {
    return JoinRequest(
      id: id,
      employeeId: employeeId,
      companyId: companyId,
      siteName: siteName,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

class ReportMetric {
  const ReportMetric({
    required this.label,
    required this.value,
    required this.delta,
  });

  final String label;
  final String value;
  final String delta;
}

class PaymentScheduleEntry {
  const PaymentScheduleEntry({
    required this.employeeName,
    required this.period,
    required this.validAttendances,
    required this.totalHours,
    required this.status,
  });

  final String employeeName;
  final String period;
  final int validAttendances;
  final double totalHours;
  final String status;
}

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class GpsValidationResult {
  const GpsValidationResult({
    required this.available,
    required this.insideZone,
    required this.distanceMeters,
    required this.message,
  });

  final bool available;
  final bool insideZone;
  final double distanceMeters;
  final String message;
}

class GpsValidator {
  const GpsValidator();

  GpsValidationResult validate({
    required WorkStop stop,
    required GeoPoint? currentLocation,
  }) {
    if (currentLocation == null) {
      return const GpsValidationResult(
        available: false,
        insideZone: false,
        distanceMeters: 0,
        message: 'GPS no disponible. Activa ubicacion e internet.',
      );
    }
    final distance = distanceInMeters(
      stop.latitude,
      stop.longitude,
      currentLocation.latitude,
      currentLocation.longitude,
    );
    final inside = distance <= stop.radiusMeters;
    return GpsValidationResult(
      available: true,
      insideZone: inside,
      distanceMeters: distance,
      message: inside
          ? 'Ubicacion validada dentro de la zona autorizada.'
          : 'Estas fuera del radio autorizado de marcacion.',
    );
  }

  double distanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_toRadians(lat1)) *
                cos(_toRadians(lat2)) *
                sin(dLon / 2) *
                sin(dLon / 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}

class MarcaYAState extends ChangeNotifier {
  final List<AppUser> users = [];
  final List<WorkStop> stops = [];
  final List<AttendanceRecord> attendanceRecords = [];
  final List<JoinRequest> joinRequests = [];

  AppUser? currentUser;
  GpsScenario gpsScenario = GpsScenario.insideZone;

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void setGpsScenario(GpsScenario scenario) {
    gpsScenario = scenario;
    notifyListeners();
  }

  List<AttendanceRecord> recordsForEmployee(String employeeId) {
    return attendanceRecords
        .where((record) => record.employeeId == employeeId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<AttendanceRecord> reportRecords({String? employeeId, String? stopId}) {
    return attendanceRecords.where((record) {
      final matchesEmployee =
          employeeId == null || record.employeeId == employeeId;
      final matchesStop = stopId == null || record.stopId == stopId;
      return matchesEmployee && matchesStop;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  double workedHoursFor(String employeeId) {
    final records = recordsForEmployee(employeeId).reversed.toList();
    DateTime? entry;
    var totalMinutes = 0;
    for (final record in records) {
      if (record.type == AttendanceType.entry) {
        entry = record.timestamp;
      }
      if (record.type == AttendanceType.exit && entry != null) {
        totalMinutes += record.timestamp.difference(entry).inMinutes.abs();
        entry = null;
      }
    }
    return totalMinutes / 60;
  }

  void updateStopRadius(String stopId, double radiusMeters) {
    final index = stops.indexWhere((stop) => stop.id == stopId);
    if (index == -1) return;
    stops[index] = stops[index].copyWith(radiusMeters: radiusMeters);
    notifyListeners();
  }

  WorkStop stopById(String id) => stops.firstWhere((stop) => stop.id == id);

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
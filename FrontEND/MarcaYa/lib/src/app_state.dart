import 'dart:math';

import 'package:flutter/foundation.dart';

enum UserRole { employee, admin }

enum AttendanceType { entry, exit }

enum RequestStatus { pending, accepted, rejected }

enum GpsScenario { insideZone, outsideZone, unavailable }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.employeeId,
    this.companyId,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? employeeId;
  final String? companyId;
}

class Employee {
  const Employee({
    required this.id,
    required this.fullName,
    required this.document,
    required this.position,
    required this.companyId,
    required this.assignedStopId,
    required this.active,
    required this.rating,
  });

  final String id;
  final String fullName;
  final String document;
  final String position;
  final String companyId;
  final String assignedStopId;
  final bool active;
  final double rating;

  Employee copyWith({bool? active, String? assignedStopId}) {
    return Employee(
      id: id,
      fullName: fullName,
      document: document,
      position: position,
      companyId: companyId,
      assignedStopId: assignedStopId ?? this.assignedStopId,
      active: active ?? this.active,
      rating: rating,
    );
  }
}

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.ruc,
    required this.description,
  });

  final String id;
  final String name;
  final String ruc;
  final String description;
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
  MarcaYAState() {
    _seed();
  }

  final _gpsValidator = const GpsValidator();
  final List<AppUser> users = [];
  final List<Employee> employees = [];
  final List<Company> companies = [];
  final List<WorkStop> stops = [];
  final List<AttendanceRecord> attendanceRecords = [];
  final List<JoinRequest> joinRequests = [];

  AppUser? currentUser;
  GpsScenario gpsScenario = GpsScenario.insideZone;

  bool login(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    for (final user in users) {
      if (user.email == normalizedEmail && user.password == password) {
        currentUser = user;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void setGpsScenario(GpsScenario scenario) {
    gpsScenario = scenario;
    notifyListeners();
  }

  Employee? get currentEmployee {
    final id = currentUser?.employeeId;
    if (id == null) return null;
    return employees.where((employee) => employee.id == id).firstOrNull;
  }

  Company? get currentCompany {
    final companyId = currentUser?.companyId ?? currentEmployee?.companyId;
    if (companyId == null) return null;
    return companies.where((company) => company.id == companyId).firstOrNull;
  }

  WorkStop? get assignedStop {
    final stopId = currentEmployee?.assignedStopId;
    if (stopId == null) return null;
    return stops.where((stop) => stop.id == stopId).firstOrNull;
  }

  GpsValidationResult? get employeeGpsValidation {
    final stop = assignedStop;
    if (stop == null) return null;
    return _gpsValidator.validate(
      stop: stop,
      currentLocation: _simulatedLocation(stop),
    );
  }

  AttendanceRecord? get lastAttendance {
    final employeeId = currentEmployee?.id;
    if (employeeId == null) return null;
    final records = recordsForEmployee(employeeId);
    return records.firstOrNull;
  }

  AttendanceRecord? markAttendance(AttendanceType type) {
    final employee = currentEmployee;
    final stop = assignedStop;
    if (employee == null || stop == null) return null;
    final location = _simulatedLocation(stop);
    final result = _gpsValidator.validate(
      stop: stop,
      currentLocation: location,
    );
    if (!result.available || !result.insideZone || location == null) {
      return null;
    }

    final record = AttendanceRecord(
      id: 'att-${attendanceRecords.length + 1}',
      employeeId: employee.id,
      stopId: stop.id,
      timestamp: DateTime.now(),
      type: type,
      validGps: true,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    attendanceRecords.add(record);
    notifyListeners();
    return record;
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

  void addStop({
    required String name,
    required String siteName,
    required double radiusMeters,
  }) {
    final company = currentCompany ?? companies.first;
    final base = stops.first;
    stops.add(
      WorkStop(
        id: 'stop-${stops.length + 1}',
        companyId: company.id,
        name: name,
        siteName: siteName,
        latitude: base.latitude + 0.001 * stops.length,
        longitude: base.longitude - 0.001 * stops.length,
        radiusMeters: radiusMeters,
        active: true,
        employeeIds: const [],
      ),
    );
    notifyListeners();
  }

  void updateStopRadius(String stopId, double radiusMeters) {
    final index = stops.indexWhere((stop) => stop.id == stopId);
    if (index == -1) return;
    stops[index] = stops[index].copyWith(radiusMeters: radiusMeters);
    notifyListeners();
  }

  bool deleteStop(String stopId) {
    final hasEmployees = employees.any(
          (employee) => employee.assignedStopId == stopId,
    );
    final hasAttendance = attendanceRecords.any(
          (record) => record.stopId == stopId,
    );
    if (hasEmployees || hasAttendance) return false;
    stops.removeWhere((stop) => stop.id == stopId);
    notifyListeners();
    return true;
  }

  void decideRequest(String requestId, RequestStatus status) {
    final index = joinRequests.indexWhere((request) => request.id == requestId);
    if (index == -1) return;
    joinRequests[index] = joinRequests[index].copyWith(status: status);
    if (status == RequestStatus.accepted) {
      final employeeIndex = employees.indexWhere(
            (employee) => employee.id == joinRequests[index].employeeId,
      );
      if (employeeIndex != -1) {
        employees[employeeIndex] = employees[employeeIndex].copyWith(
          active: true,
        );
      }
    }
    notifyListeners();
  }

  void createJoinRequest() {
    final employee = currentEmployee;
    final company = companies.first;
    if (employee == null) return;
    final exists = joinRequests.any(
          (request) =>
      request.employeeId == employee.id &&
          request.status == RequestStatus.pending,
    );
    if (exists) return;
    joinRequests.add(
      JoinRequest(
        id: 'req-${joinRequests.length + 1}',
        employeeId: employee.id,
        companyId: company.id,
        siteName: 'Obra Central Lima',
        createdAt: DateTime.now(),
        status: RequestStatus.pending,
      ),
    );
    notifyListeners();
  }

  List<ReportMetric> get dashboardMetrics {
    final valid = attendanceRecords.where((record) => record.validGps).length;
    final rate = attendanceRecords.isEmpty
        ? 0
        : (valid / attendanceRecords.length * 100).round();
    return [
      ReportMetric(
        label: 'Marcaciones hoy',
        value: '${attendanceRecords.length}',
        delta: '+12%',
      ),
      ReportMetric(label: 'Asistencia valida', value: '$rate%', delta: '+8%'),
      const ReportMetric(label: 'Tardanzas', value: '2', delta: '-1 vs ayer'),
      const ReportMetric(
        label: 'Horas trabajadas',
        value: '126 h',
        delta: '+18 h',
      ),
    ];
  }

  List<PaymentScheduleEntry> get paymentSchedule {
    return employees.where((employee) => employee.active).map((employee) {
      return PaymentScheduleEntry(
        employeeName: employee.fullName,
        period: 'Mayo 2026',
        validAttendances: recordsForEmployee(
          employee.id,
        ).where((record) => record.validGps).length,
        totalHours: workedHoursFor(employee.id),
        status: 'Listo para cronograma',
      );
    }).toList();
  }

  Employee employeeById(String id) =>
      employees.firstWhere((employee) => employee.id == id);

  WorkStop stopById(String id) => stops.firstWhere((stop) => stop.id == id);

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  GeoPoint? _simulatedLocation(WorkStop stop) {
    return switch (gpsScenario) {
      GpsScenario.insideZone => GeoPoint(
        stop.latitude + 0.00008,
        stop.longitude + 0.00008,
      ),
      GpsScenario.outsideZone => GeoPoint(
        stop.latitude + 0.009,
        stop.longitude - 0.009,
      ),
      GpsScenario.unavailable => null,
    };
  }

  void _seed() {
    companies.add(
      const Company(
        id: 'company-1',
        name: 'Constructora Andina SAC',
        ruc: '20548796321',
        description:
        'Empresa de obras civiles que controla asistencia en paradas autorizadas.',
      ),
    );
    stops.addAll([
      const WorkStop(
        id: 'stop-1',
        companyId: 'company-1',
        name: 'Puerta Norte',
        siteName: 'Obra Central Lima',
        latitude: -12.0841,
        longitude: -77.0336,
        radiusMeters: 120,
        active: true,
        employeeIds: ['emp-1', 'emp-2'],
      ),
      const WorkStop(
        id: 'stop-2',
        companyId: 'company-1',
        name: 'Almacen Sur',
        siteName: 'Edificio Miraflores',
        latitude: -12.1217,
        longitude: -77.0299,
        radiusMeters: 90,
        active: true,
        employeeIds: ['emp-3'],
      ),
    ]);
    employees.addAll([
      const Employee(
        id: 'emp-1',
        fullName: 'Luis Ramirez Soto',
        document: '45879631',
        position: 'Operario de obra',
        companyId: 'company-1',
        assignedStopId: 'stop-1',
        active: true,
        rating: 4.7,
      ),
      const Employee(
        id: 'emp-2',
        fullName: 'Mariana Torres Vega',
        document: '47236982',
        position: 'Supervisora de campo',
        companyId: 'company-1',
        assignedStopId: 'stop-1',
        active: true,
        rating: 4.9,
      ),
      const Employee(
        id: 'emp-3',
        fullName: 'Carlos Diaz Prado',
        document: '43219876',
        position: 'Tecnico electrico',
        companyId: 'company-1',
        assignedStopId: 'stop-2',
        active: false,
        rating: 4.3,
      ),
    ]);
    users.addAll([
      const AppUser(
        id: 'user-1',
        name: 'Luis Ramirez',
        email: 'empleado@marcapp.pe',
        password: '123456',
        role: UserRole.employee,
        employeeId: 'emp-1',
      ),
      const AppUser(
        id: 'user-2',
        name: 'Admin MarcaYA',
        email: 'admin@marcapp.pe',
        password: '123456',
        role: UserRole.admin,
        companyId: 'company-1',
      ),
      const AppUser(
        id: 'user-3',
        name: 'Carlos Diaz',
        email: 'carlos@marcapp.pe',
        password: '123456',
        role: UserRole.employee,
        employeeId: 'emp-3',
      ),
    ]);
    final now = DateTime.now();
    attendanceRecords.addAll([
      AttendanceRecord(
        id: 'att-1',
        employeeId: 'emp-1',
        stopId: 'stop-1',
        timestamp: now.subtract(const Duration(days: 1, hours: 9)),
        type: AttendanceType.entry,
        validGps: true,
        latitude: -12.0840,
        longitude: -77.0335,
      ),
      AttendanceRecord(
        id: 'att-2',
        employeeId: 'emp-1',
        stopId: 'stop-1',
        timestamp: now.subtract(const Duration(days: 1)),
        type: AttendanceType.exit,
        validGps: true,
        latitude: -12.0840,
        longitude: -77.0335,
      ),
      AttendanceRecord(
        id: 'att-3',
        employeeId: 'emp-2',
        stopId: 'stop-1',
        timestamp: now.subtract(const Duration(hours: 6)),
        type: AttendanceType.entry,
        validGps: true,
        latitude: -12.0842,
        longitude: -77.0336,
      ),
    ]);
    joinRequests.add(
      JoinRequest(
        id: 'req-1',
        employeeId: 'emp-3',
        companyId: 'company-1',
        siteName: 'Edificio Miraflores',
        createdAt: now.subtract(const Duration(days: 2)),
        status: RequestStatus.pending,
      ),
    );
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
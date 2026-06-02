import 'package:flutter_test/flutter_test.dart';
import 'package:marcapp/src/app_state.dart';

void main() {
  group('GpsValidator', () {
    test('accepts points inside the configured radius', () {
      const validator = GpsValidator();
      const stop = WorkStop(
        id: 'stop',
        companyId: 'company',
        name: 'Puerta',
        siteName: 'Obra',
        latitude: -12.0841,
        longitude: -77.0336,
        radiusMeters: 120,
        active: true,
        employeeIds: [],
      );

      final result = validator.validate(
        stop: stop,
        currentLocation: const GeoPoint(-12.0840, -77.0335),
      );

      expect(result.available, isTrue);
      expect(result.insideZone, isTrue);
    });

    test('rejects unavailable and outside-zone points', () {
      const validator = GpsValidator();
      const stop = WorkStop(
        id: 'stop',
        companyId: 'company',
        name: 'Puerta',
        siteName: 'Obra',
        latitude: -12.0841,
        longitude: -77.0336,
        radiusMeters: 80,
        active: true,
        employeeIds: [],
      );

      final unavailable = validator.validate(stop: stop, currentLocation: null);
      final outside = validator.validate(
        stop: stop,
        currentLocation: const GeoPoint(-12.0740, -77.0435),
      );

      expect(unavailable.available, isFalse);
      expect(outside.insideZone, isFalse);
    });

    test('distanceInMeters returns correct value', () {
      const validator = GpsValidator();

      // Same point → 0 distance
      final zero = validator.distanceInMeters(-12.0, -77.0, -12.0, -77.0);
      expect(zero, closeTo(0, 0.1));

      // ~111km per degree of latitude at the equator
      final oneDegree = validator.distanceInMeters(0, 0, 1, 0);
      expect(oneDegree, closeTo(111_195, 500));
    });
  });

  group('AppUser.fromJson', () {
    test('parses empleado login response (snake_case)', () {
      final json = <String, dynamic>{
        'id': 1,
        'employee_id': 1,
        'correo': 'empleado@test.com',
        'rol': 'empleado',
        'nombre': 'Juan',
        'apellido': 'Perez',
        'descripcion': 'Operario de obra',
        'telefono': '999888777',
        'foto_url': null,
      };

      final user = AppUser.fromJson(json);

      expect(user.id, '1');
      expect(user.nombre, 'Juan');
      expect(user.correo, 'empleado@test.com');
      expect(user.rol, UserRole.employee);
      expect(user.employeeId, '1');
      expect(user.apellido, 'Perez');
      expect(user.descripcion, 'Operario de obra');
      expect(user.telefono, '999888777');
      expect(user.fotoUrl, isNull);
    });

    test('parses empresa login response (snake_case)', () {
      final json = <String, dynamic>{
        'id': 2,
        'correo': 'admin@test.com',
        'rol': 'empresa',
        'nombre': 'Constructora SAC',
        'nombre_empresa': 'Constructora SAC',
        'descripcion': 'Empresa constructora',
        'telefono': '111222333',
        'direccion': 'Av. Principal 123',
        'ruc': '20548796321',
        'foto_url': null,
      };

      final user = AppUser.fromJson(json);

      expect(user.id, '2');
      expect(user.nombre, 'Constructora SAC');
      expect(user.rol, UserRole.empresa);
      expect(user.nombreEmpresa, 'Constructora SAC');
      expect(user.direccion, 'Av. Principal 123');
      expect(user.ruc, '20548796321');
      expect(user.employeeId, isNull);
    });

    test('parses numeric id and snake_case fechaRegistro fallback', () {
      final json = <String, dynamic>{
        'id': 3,
        'nombre': 'Test',
        'correo': 'test@test.com',
        'rol': 'empleado',
        'estado': 'activo',
        'fechaRegistro': '2026-01-15T10:00:00.000Z',
      };

      final user = AppUser.fromJson(json);

      expect(user.id, '3');
      expect(user.fechaRegistro, isNotNull);
      expect(user.fechaRegistro!.year, 2026);
      expect(user.fechaRegistro!.month, 1);
      expect(user.fechaRegistro!.day, 15);
    });

    test('parses created_at field for fechaRegistro', () {
      final json = <String, dynamic>{
        'id': 4,
        'nombre': 'Test',
        'correo': 'test@test.com',
        'rol': 'empleado',
        'created_at': '2026-06-01T12:00:00.000Z',
      };

      final user = AppUser.fromJson(json);

      expect(user.fechaRegistro, isNotNull);
      expect(user.fechaRegistro!.year, 2026);
      expect(user.fechaRegistro!.month, 6);
      expect(user.fechaRegistro!.day, 1);
    });

    test('handles promedio_estrellas as number', () {
      final json = <String, dynamic>{
        'id': 5,
        'nombre': 'Test',
        'correo': 'test@test.com',
        'rol': 'empleado',
        'promedio_estrellas': 4.5,
      };

      final user = AppUser.fromJson(json);

      expect(user.promedioEstrellas, 4.5);
    });

    test('handles null fields gracefully', () {
      final json = <String, dynamic>{
        'id': null,
        'nombre': null,
        'correo': null,
        'rol': 'unknown',
      };

      final user = AppUser.fromJson(json);

      expect(user.id, '');
      expect(user.nombre, '');
      expect(user.correo, '');
      expect(user.rol, UserRole.employee); // fallback for unknown rol
    });

    test('toJson returns only nombre and correo', () {
      final user = AppUser(
        id: '1',
        nombre: 'Juan',
        correo: 'juan@test.com',
        rol: UserRole.employee,
      );

      final json = user.toJson();

      expect(json['nombre'], 'Juan');
      expect(json['correo'], 'juan@test.com');
      expect(json.length, 2);
    });
  });

  group('MarcaYAState formatting helpers', () {
    test('formatDate returns DD/MM/YYYY', () {
      final state = MarcaYAState();
      final date = DateTime(2026, 6, 1);
      expect(state.formatDate(date), '01/06/2026');
    });

    test('formatTime returns HH:MM', () {
      final state = MarcaYAState();
      final date = DateTime(2026, 6, 1, 14, 30);
      expect(state.formatTime(date), '14:30');
    });
  });
}

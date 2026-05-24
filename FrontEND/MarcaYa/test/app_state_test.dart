import 'package:flutter_test/flutter_test.dart';
import 'package:marcapp/src/app_state.dart';

void main() {
  test('GPS validation accepts points inside the configured radius', () {
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

  test('GPS validation rejects unavailable and outside-zone points', () {
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

  test('employee can mark entry and exit only with valid GPS', () {
    final state = MarcAppState();
    expect(state.login('empleado@marcapp.pe', '123456'), isTrue);

    state.setGpsScenario(GpsScenario.insideZone);
    final entry = state.markAttendance(AttendanceType.entry);
    final exit = state.markAttendance(AttendanceType.exit);

    expect(entry, isNotNull);
    expect(exit, isNotNull);
    final records = state.recordsForEmployee('emp-1');
    expect(records.any((record) => record.id == entry!.id), isTrue);
    expect(records.any((record) => record.id == exit!.id), isTrue);

    state.setGpsScenario(GpsScenario.outsideZone);
    final blocked = state.markAttendance(AttendanceType.entry);
    expect(blocked, isNull);
  });

  test('admin can accept and reject employee requests', () {
    final state = MarcAppState();
    expect(state.joinRequests.first.status, RequestStatus.pending);

    state.decideRequest('req-1', RequestStatus.accepted);
    expect(state.joinRequests.first.status, RequestStatus.accepted);
    expect(state.employeeById('emp-3').active, isTrue);

    state.decideRequest('req-1', RequestStatus.rejected);
    expect(state.joinRequests.first.status, RequestStatus.rejected);
  });

  test('reports filter records by employee and stop', () {
    final state = MarcAppState();
    final employeeRecords = state.reportRecords(employeeId: 'emp-1');
    final stopRecords = state.reportRecords(stopId: 'stop-1');

    expect(employeeRecords, isNotEmpty);
    expect(
      employeeRecords.every((record) => record.employeeId == 'emp-1'),
      isTrue,
    );
    expect(stopRecords.every((record) => record.stopId == 'stop-1'), isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:marcapp/models/marcacion_pendiente.dart';
import 'package:marcapp/repositories/marcacion_pendiente_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late MarcacionPendienteRepository repository;

  setUpAll(sqfliteFfiInit);

  setUp(() {
    repository = MarcacionPendienteRepository(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
  });

  tearDown(() async {
    await repository.close();
  });

  MarcacionPendiente marcacion(String id, DateTime fecha) {
    return MarcacionPendiente(
      clienteMarcacionId: id,
      paradaId: 10,
      tipoMarcacion: 'ENTRADA',
      latitud: -12.119,
      longitud: -77.034,
      marcadaEn: fecha,
    );
  }

  test('empty storage returns no pending records', () async {
    expect(await repository.obtenerPendientes(), isEmpty);
    expect(await repository.contarPendientes(), 0);
  });

  test('stores pending state, original time and required data', () async {
    final fecha = DateTime.utc(2026, 7, 12, 14, 30);
    await repository.guardar(marcacion('offline-1', fecha));

    final records = await repository.obtenerPendientes();

    expect(records, hasLength(1));
    expect(records.single.estado, MarcacionPendiente.estadoPendiente);
    expect(records.single.marcadaEn, fecha);
    expect(records.single.clienteMarcacionId, 'offline-1');
    expect(records.single.paradaId, 10);
    expect(records.single.tipoMarcacion, 'ENTRADA');
    expect(records.single.latitud, -12.119);
    expect(records.single.longitud, -77.034);
  });

  test('deletes only backend-confirmed client ids', () async {
    await repository.guardar(
      marcacion('offline-ok', DateTime.utc(2026, 7, 12, 8)),
    );
    await repository.guardar(
      marcacion('offline-failed', DateTime.utc(2026, 7, 12, 9)),
    );

    await repository.eliminarPorClienteIds(['offline-ok']);

    final records = await repository.obtenerPendientes();
    expect(records.map((record) => record.clienteMarcacionId), [
      'offline-failed',
    ]);
  });

  test('records synchronization errors without deleting local row', () async {
    await repository.guardar(
      marcacion('offline-1', DateTime.utc(2026, 7, 12, 8)),
    );

    await repository.registrarErrores({'offline-1': 'HTTP 500'});
    await repository.registrarErrores({'offline-1': 'timeout'});

    final records = await repository.obtenerPendientes();
    expect(records, hasLength(1));
    expect(records.single.intentos, 2);
    expect(records.single.ultimoError, 'timeout');
  });

  test('duplicate id is idempotent in local storage', () async {
    final record = marcacion('offline-1', DateTime.utc(2026, 7, 12, 8));

    await repository.guardar(record);
    await repository.guardar(record);

    expect(await repository.contarPendientes(), 1);
  });
}

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/marcacion_pendiente.dart';

class MarcacionPendienteRepository {
  MarcacionPendienteRepository({
    DatabaseFactory? factory,
    String? databasePath,
  })  : _factory = factory,
        _databasePath = databasePath;

  static const _databaseName = 'marcaya_offline.db';
  static const _databaseVersion = 1;
  static const tableName = 'marcaciones_pendientes';

  Database? _database;
  final DatabaseFactory? _factory;
  final String? _databasePath;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final factory = _factory ?? databaseFactory;
    final dbPath = await factory.getDatabasesPath();
    final path = _databasePath ?? p.join(dbPath, _databaseName);
    _database = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_marcacion_id TEXT NOT NULL UNIQUE,
            parada_id INTEGER NOT NULL,
            tipo_marcacion TEXT NOT NULL,
            latitud REAL NOT NULL,
            longitud REAL NOT NULL,
            marcada_en TEXT NOT NULL,
            estado TEXT NOT NULL,
            intentos INTEGER NOT NULL DEFAULT 0,
            ultimo_error TEXT,
            creada_en TEXT NOT NULL
          )
        ''');
        },
      ),
    );
    return _database!;
  }

  Future<void> guardar(MarcacionPendiente marcacion) async {
    final db = await database;
    await db.insert(
      tableName,
      marcacion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<MarcacionPendiente>> obtenerPendientes() async {
    final db = await database;
    final rows = await db.query(
      tableName,
      where: 'estado = ?',
      whereArgs: [MarcacionPendiente.estadoPendiente],
      orderBy: 'marcada_en ASC',
    );
    return rows.map(MarcacionPendiente.fromMap).toList();
  }

  Future<int> contarPendientes() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $tableName WHERE estado = ?',
      [MarcacionPendiente.estadoPendiente],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> eliminarPorClienteIds(List<String> clienteIds) async {
    if (clienteIds.isEmpty) return;

    final db = await database;
    final placeholders = List.filled(clienteIds.length, '?').join(',');
    await db.delete(
      tableName,
      where: 'cliente_marcacion_id IN ($placeholders)',
      whereArgs: clienteIds,
    );
  }

  Future<void> registrarErrores(Map<String, String> errores) async {
    if (errores.isEmpty) return;

    final db = await database;
    final batch = db.batch();
    for (final entry in errores.entries) {
      batch.rawUpdate(
        '''
        UPDATE $tableName
        SET intentos = intentos + 1,
            ultimo_error = ?
        WHERE cliente_marcacion_id = ?
        ''',
        [entry.value, entry.key],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

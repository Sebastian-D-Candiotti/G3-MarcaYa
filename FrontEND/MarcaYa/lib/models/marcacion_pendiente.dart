class MarcacionPendiente {
  static const estadoPendiente = 'PENDIENTE_SINCRONIZACION';

  const MarcacionPendiente({
    this.id,
    required this.clienteMarcacionId,
    required this.paradaId,
    required this.tipoMarcacion,
    required this.latitud,
    required this.longitud,
    required this.marcadaEn,
    this.estado = estadoPendiente,
    this.intentos = 0,
    this.ultimoError,
    DateTime? creadaEn,
  }) : creadaEn = creadaEn ?? marcadaEn;

  final int? id;
  final String clienteMarcacionId;
  final int paradaId;
  final String tipoMarcacion;
  final double latitud;
  final double longitud;
  final DateTime marcadaEn;
  final String estado;
  final int intentos;
  final String? ultimoError;
  final DateTime creadaEn;

  factory MarcacionPendiente.nueva({
    required int paradaId,
    required String tipoMarcacion,
    required double latitud,
    required double longitud,
    required DateTime marcadaEn,
  }) {
    final normalizado = tipoMarcacion.toUpperCase();
    final timestamp = marcadaEn.toUtc().microsecondsSinceEpoch;
    return MarcacionPendiente(
      clienteMarcacionId: 'offline-$timestamp-$paradaId-$normalizado',
      paradaId: paradaId,
      tipoMarcacion: normalizado,
      latitud: latitud,
      longitud: longitud,
      marcadaEn: marcadaEn,
    );
  }

  factory MarcacionPendiente.fromMap(Map<String, Object?> map) {
    return MarcacionPendiente(
      id: map['id'] as int?,
      clienteMarcacionId: map['cliente_marcacion_id'] as String,
      paradaId: map['parada_id'] as int,
      tipoMarcacion: map['tipo_marcacion'] as String,
      latitud: (map['latitud'] as num).toDouble(),
      longitud: (map['longitud'] as num).toDouble(),
      marcadaEn: DateTime.parse(map['marcada_en'] as String),
      estado: map['estado'] as String,
      intentos: map['intentos'] as int? ?? 0,
      ultimoError: map['ultimo_error'] as String?,
      creadaEn: DateTime.parse(map['creada_en'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'cliente_marcacion_id': clienteMarcacionId,
      'parada_id': paradaId,
      'tipo_marcacion': tipoMarcacion,
      'latitud': latitud,
      'longitud': longitud,
      'marcada_en': marcadaEn.toUtc().toIso8601String(),
      'estado': estado,
      'intentos': intentos,
      'ultimo_error': ultimoError,
      'creada_en': creadaEn.toUtc().toIso8601String(),
    };
  }

  Map<String, Object?> toSyncJson() {
    return {
      'cliente_marcacion_id': clienteMarcacionId,
      'parada_id': paradaId,
      'tipo_marcacion': tipoMarcacion,
      'latitud': latitud,
      'longitud': longitud,
      'fecha_hora_original': marcadaEn.toUtc().toIso8601String(),
    };
  }
}

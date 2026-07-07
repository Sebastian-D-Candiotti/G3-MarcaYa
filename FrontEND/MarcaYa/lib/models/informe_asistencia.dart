class InformeAsistencia {
  const InformeAsistencia({
    required this.id,
    required this.tipoPeriodo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.checksum,
    required this.version,
    required this.snapshot,
  });

  final int id;
  final String tipoPeriodo;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String estado;
  final String checksum;
  final int version;
  final Map<String, dynamic> snapshot;

  factory InformeAsistencia.fromJson(Map<String, dynamic> json) {
    return InformeAsistencia(
      id: _asInt(json['id']),
      tipoPeriodo: json['tipo_periodo']?.toString() ?? '',
      fechaInicio: DateTime.tryParse(json['fecha_inicio']?.toString() ?? ''),
      fechaFin: DateTime.tryParse(json['fecha_fin']?.toString() ?? ''),
      estado: json['estado']?.toString() ?? '',
      checksum: json['checksum']?.toString() ?? '',
      version: _asInt(json['version'], fallback: 1),
      snapshot: _asMap(json['snapshot']),
    );
  }

  Map<String, dynamic> get resumen => _asMap(snapshot['resumen']);

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }
}

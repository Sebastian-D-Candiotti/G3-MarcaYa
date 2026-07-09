class EstadisticasObra {
  final int obraId;
  final String obraNombre;
  final String periodo;
  final double horasPromedio;
  final double horasTotales;
  final double puntualidadPorcentaje;
  final int diasTrabajados;
  final int tardanzasTotal;
  final int faltasTotal;
  final int fakeGpsIntentos;
  final int empleadosActivos;
  final int empleadosConIrregularidades;
  final List<DatosEmpleado> datosPorEmpleado;

  const EstadisticasObra({
    required this.obraId,
    required this.obraNombre,
    required this.periodo,
    required this.horasPromedio,
    required this.horasTotales,
    required this.puntualidadPorcentaje,
    required this.diasTrabajados,
    required this.tardanzasTotal,
    required this.faltasTotal,
    required this.fakeGpsIntentos,
    required this.empleadosActivos,
    required this.empleadosConIrregularidades,
    required this.datosPorEmpleado,
  });

  factory EstadisticasObra.fromJson(Map<String, dynamic> json) {
    return EstadisticasObra(
      obraId: _asInt(json['obra_id']),
      obraNombre: json['obra_nombre']?.toString() ?? '',
      periodo: json['periodo']?.toString() ?? '',
      horasPromedio: _asDouble(json['horas_promedio']),
      horasTotales: _asDouble(json['horas_totales']),
      puntualidadPorcentaje: _asDouble(json['puntualidad_porcentaje']),
      diasTrabajados: _asInt(json['dias_trabajados']),
      tardanzasTotal: _asInt(json['tardanzas_total']),
      faltasTotal: _asInt(json['faltas_total']),
      fakeGpsIntentos: _asInt(json['fake_gps_intentos']),
      empleadosActivos: _asInt(json['empleados_activos']),
      empleadosConIrregularidades: _asInt(
        json['empleados_con_irregularidades'],
      ),
      datosPorEmpleado: _parseDatosPorEmpleado(json['datos_por_empleado']),
    );
  }

  static List<DatosEmpleado> _parseDatosPorEmpleado(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (e) => DatosEmpleado.fromJson(
              e.map((key, val) => MapEntry(key.toString(), val)),
            ),
          )
          .toList();
    }
    return [];
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class DatosEmpleado {
  final int empleadoId;
  final String nombre;
  final double horasTrabajadas;
  final int tardanzas;
  final int faltas;
  final int fakeGps;

  const DatosEmpleado({
    required this.empleadoId,
    required this.nombre,
    required this.horasTrabajadas,
    required this.tardanzas,
    required this.faltas,
    required this.fakeGps,
  });

  factory DatosEmpleado.fromJson(Map<String, dynamic> json) {
    return DatosEmpleado(
      empleadoId: _asInt(json['empleado_id']),
      nombre: json['nombre']?.toString() ?? '',
      horasTrabajadas: _asDouble(json['horas_trabajadas']),
      tardanzas: _asInt(json['tardanzas']),
      faltas: _asInt(json['faltas']),
      fakeGps: _asInt(json['fake_gps']),
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

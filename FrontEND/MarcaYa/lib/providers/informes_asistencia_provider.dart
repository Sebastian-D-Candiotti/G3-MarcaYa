import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import '../models/informe_asistencia.dart';
import '../src/api_service.dart';

class InformesAsistenciaProvider extends ChangeNotifier {
  List<InformeAsistencia> _historial = [];
  Map<String, dynamic>? _vistaPrevia;
  bool _cargando = false;
  String? _error;
  Uint8List? _ultimoPdf;
  String? _ultimoPdfNombre;

  List<InformeAsistencia> get historial => _historial;
  Map<String, dynamic>? get vistaPrevia => _vistaPrevia;
  bool get cargando => _cargando;
  String? get error => _error;
  Uint8List? get ultimoPdf => _ultimoPdf;
  String? get ultimoPdfNombre => _ultimoPdfNombre;

  Future<void> cargarHistorial({
    String? tipoPeriodo,
    String? estado,
    int? anio,
    int? mes,
  }) async {
    await _run(() async {
      final data = await ApiService.instance.listarInformesAsistencia(
        tipoPeriodo: tipoPeriodo,
        estado: estado,
        anio: anio,
        mes: mes,
      );
      final items = data['items'] as List? ?? [];
      _historial = items
          .whereType<Map>()
          .map((item) => InformeAsistencia.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ))
          .toList();
    });
  }

  Future<void> generarVistaPrevia({
    required String tipoPeriodo,
    required String fechaInicio,
    required String fechaFin,
  }) async {
    await _run(() async {
      _vistaPrevia = await ApiService.instance.generarVistaPreviaInforme(
        tipoPeriodo: tipoPeriodo,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
    });
  }

  Future<InformeAsistencia?> cerrarMes({
    required int anio,
    required int mes,
  }) async {
    InformeAsistencia? informe;
    await _run(() async {
      final data = await ApiService.instance.cerrarMesInforme(
        anio: anio,
        mes: mes,
      );
      informe = InformeAsistencia.fromJson(data);
    });
    if (informe != null) {
      await cargarHistorial(tipoPeriodo: 'MENSUAL', anio: anio, mes: mes);
    }
    return informe;
  }

  Future<Uint8List?> descargarPdf(InformeAsistencia informe) async {
    Uint8List? bytes;
    await _run(() async {
      bytes = await ApiService.instance.descargarInformeAsistenciaPdf(informe.id);
      _ultimoPdf = bytes;
      _ultimoPdfNombre = _nombrePdf(informe);
    });
    return bytes;
  }

  Future<void> _run(Future<void> Function() action) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await action();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error en informes de asistencia: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  String _nombrePdf(InformeAsistencia informe) {
    final inicio = informe.fechaInicio;
    final periodo = inicio == null
        ? informe.id.toString()
        : '${inicio.year}_${inicio.month.toString().padLeft(2, '0')}';
    return 'informe_asistencia_$periodo.pdf';
  }
}

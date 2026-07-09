import 'package:flutter/foundation.dart';
import '../src/api_service.dart';
import '../models/estadisticas_obra.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({dynamic api}) : _api = api;

  /// In production this will be [ApiService.instance]; in tests a fake.
  final dynamic _api;

  EstadisticasObra? _estadisticas;
  bool _cargando = false;
  String? _error;

  EstadisticasObra? get estadisticas => _estadisticas;
  bool get cargando => _cargando;
  String? get error => _error;

  /// Returns the ApiService to use — singleton in production, injected in tests.
  dynamic get _service => _api ?? ApiService.instance;

  Future<void> cargarEstadisticas(int obraId, {String? periodo}) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.obtenerEstadisticasObra(
        obraId,
        periodo: periodo,
      );
      _estadisticas = EstadisticasObra.fromJson(data);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error cargando estadísticas de obra: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}

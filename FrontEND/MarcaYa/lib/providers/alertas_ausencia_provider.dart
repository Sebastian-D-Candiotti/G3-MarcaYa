import 'package:flutter/foundation.dart';
import '../src/api_service.dart';

class AlertasAusenciaProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _alertas = [];
  bool _cargando = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────
  List<Map<String, dynamic>> get alertas => _alertas;
  bool get cargando => _cargando;
  String? get error => _error;

  /// Filtra solo las alertas con estado 'pendiente'
  List<Map<String, dynamic>> get alertasPendientes =>
      _alertas.where((a) => a['estado'] == 'pendiente').toList();

  // ── Acciones ───────────────────────────────────────────────

  /// Carga todas las alertas de ausencia desde el backend
  Future<void> loadAlertas() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final raw = await ApiService.instance.obtenerAlertasAusencia();
      _alertas = raw.cast<Map<String, dynamic>>();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error cargando alertas de ausencia: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Resuelve una alerta por ID y la remueve de la lista local
  Future<void> resolverAlerta(int id) async {
    try {
      await ApiService.instance.resolverAlerta(id);
      _alertas.removeWhere((a) => a['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error resolviendo alerta: $e');
      rethrow;
    }
  }
}

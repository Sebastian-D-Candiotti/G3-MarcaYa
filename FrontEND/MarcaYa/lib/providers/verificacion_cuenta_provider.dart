import 'package:flutter/foundation.dart';

import '../src/api_service.dart';

class VerificacionCuentaProvider extends ChangeNotifier {
  VerificacionCuentaProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> verificarCodigo({
    required String correo,
    required String codigo,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final data = await _apiService.verificarCuenta(
        correo: correo,
        codigo: codigo,
      );
      final usuario = data['usuario'] as Map<String, dynamic>?;
      final estado = usuario?['estado_verificacion']?.toString();
      return estado == 'ACTIVO';
    } on ApiException catch (e) {
      _error = _mapError(e.mensaje);
      return false;
    } catch (_) {
      _error = 'Error de conexión. Inténtalo nuevamente.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> reenviarCodigo({required String correo}) async {
    _setLoading(true);
    _error = null;

    try {
      await _apiService.reenviarCodigoVerificacion(correo: correo);
      return true;
    } on ApiException catch (e) {
      _error = _mapError(e.mensaje);
      return false;
    } catch (_) {
      _error = 'Error de conexión. Inténtalo nuevamente.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapError(String mensaje) {
    final normalizado = mensaje.toLowerCase();
    if (normalizado.contains('incorrecto')) {
      return 'Código incorrecto. Revisa el correo e inténtalo otra vez.';
    }
    if (normalizado.contains('vencido')) {
      return 'Código vencido. Solicita un nuevo código.';
    }
    if (normalizado.contains('utilizado') ||
        normalizado.contains('verificada')) {
      return 'Este código ya fue usado o la cuenta ya está verificada.';
    }
    if (normalizado.contains('usuario no encontrado')) {
      return 'Usuario no encontrado. Vuelve a completar el registro.';
    }
    return mensaje;
  }
}

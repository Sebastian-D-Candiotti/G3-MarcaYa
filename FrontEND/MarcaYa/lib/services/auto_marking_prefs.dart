// lib/services/auto_marking_prefs.dart
// SharedPreferences wrapper para datos de marcación automática.
// Diseñado para ser accesible desde Isolates (a diferencia de FlutterSecureStorage).

import 'package:shared_preferences/shared_preferences.dart';

class AutoMarkingPrefs {
  AutoMarkingPrefs._();

  // ── Keys ────────────────────────────────────────────────────
  static const _kEnabled = 'auto_marking';
  static const _kToken = 'auto_marking_jwt_token';
  static const _kParadaId = 'auto_marking_parada_id';
  static const _kParadaLat = 'auto_marking_parada_lat';
  static const _kParadaLng = 'auto_marking_parada_lng';
  static const _kParadaRadio = 'auto_marking_parada_radio';
  static const _kParadaNombre = 'auto_marking_parada_nombre';
  static const _kObraNombre = 'auto_marking_obra_nombre';
  static const _kTurnoHoraInicio = 'auto_marking_turno_hora_inicio';
  static const _kBaseUrl = 'auto_marking_base_url';

  // ── Estado del switch ───────────────────────────────────────

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabled) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, value);
  }

  // ── Token JWT (copia para acceso desde Isolate) ─────────────

  static Future<void> saveToken(String jwt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, jwt);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  // ── URL base del backend ───────────────────────────────────

  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBaseUrl, url);
  }

  static Future<String?> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kBaseUrl);
  }

  // ── Datos de la parada asignada ─────────────────────────────

  static Future<void> saveParadaData({
    required int paradaId,
    required double latitud,
    required double longitud,
    required double radio,
    required String paradaNombre,
    required String obraNombre,
    required String turnoHoraInicio,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kParadaId, paradaId);
    await prefs.setDouble(_kParadaLat, latitud);
    await prefs.setDouble(_kParadaLng, longitud);
    await prefs.setDouble(_kParadaRadio, radio);
    await prefs.setString(_kParadaNombre, paradaNombre);
    await prefs.setString(_kObraNombre, obraNombre);
    await prefs.setString(_kTurnoHoraInicio, turnoHoraInicio);
  }

  /// Retorna null si no hay datos guardados.
  static Future<Map<String, dynamic>?> getParadaData() async {
    final prefs = await SharedPreferences.getInstance();
    final paradaId = prefs.getInt(_kParadaId);
    if (paradaId == null) return null;

    return {
      'parada_id': paradaId,
      'latitud': prefs.getDouble(_kParadaLat) ?? 0.0,
      'longitud': prefs.getDouble(_kParadaLng) ?? 0.0,
      'radio': prefs.getDouble(_kParadaRadio) ?? 50.0,
      'parada_nombre': prefs.getString(_kParadaNombre) ?? '',
      'obra_nombre': prefs.getString(_kObraNombre) ?? '',
      'turno_hora_inicio': prefs.getString(_kTurnoHoraInicio) ?? '08:00',
    };
  }

  /// Hora de inicio del turno como DateTime del día actual.
  static Future<DateTime?> getTurnoHoraInicioAsDateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final horaStr = prefs.getString(_kTurnoHoraInicio);
    if (horaStr == null) return null;

    final parts = horaStr.split(':');
    if (parts.length < 2) return null;

    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 8,
      int.tryParse(parts[1]) ?? 0,
    );
  }

  // ── Limpieza total ──────────────────────────────────────────

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEnabled);
    await prefs.remove(_kToken);
    await prefs.remove(_kParadaId);
    await prefs.remove(_kParadaLat);
    await prefs.remove(_kParadaLng);
    await prefs.remove(_kParadaRadio);
    await prefs.remove(_kParadaNombre);
    await prefs.remove(_kObraNombre);
    await prefs.remove(_kTurnoHoraInicio);
    await prefs.remove(_kBaseUrl);
  }
}

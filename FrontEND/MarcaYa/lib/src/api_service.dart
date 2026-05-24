// lib/src/api_service.dart
// Reemplaza la lógica simulada de MarcAppState por llamadas HTTP reales

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── CAMBIA ESTA URL SEGÚN DONDE CORRA TU BACKEND ───────────
// Emulador Android:  http://10.0.2.2:3000/api/v1
// Dispositivo físico: http://TU_IP_LOCAL:3000/api/v1  (ej: 192.168.1.5)
// Producción:        https://tu-dominio.com/api/v1
const String kBaseUrl = 'http://localhost:3000/api/v1';

// ────────────────────────────────────────────────────────────

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final _storage = const FlutterSecureStorage();
  final _client  = http.Client();

  // ── Token JWT ──────────────────────────────────────────────
  Future<void> _guardarToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> borrarToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  // ── Headers con autorización ───────────────────────────────
  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Manejo de errores ──────────────────────────────────────
  Map<String, dynamic> _parsearRespuesta(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw ApiException(body['error'] ?? 'Error desconocido', res.statusCode);
    }
    return body;
  }

  // ════════════════════════════════════════════════════════════
  // AUTH
  // ════════════════════════════════════════════════════════════

  /// Login → retorna el rol del usuario ('empresa' | 'empleado')
  Future<LoginResult> login(String correo, String clave) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/auth/login'),
      headers: await _headers(auth: false),
      body: jsonEncode({'correo': correo, 'clave': clave}),
    );

    final data = _parsearRespuesta(res);
    await _guardarToken(data['token'] as String);

    return LoginResult(
      token:  data['token'] as String,
      rol:    data['rol']   as String,
      perfil: data['perfil'] as Map<String, dynamic>,
    );
  }

  /// Registro de empresa
  Future<void> registrarEmpresa({
    required String correo,
    required String clave,
    required String ruc,
    required String razonSocial,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/auth/registro'),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'correo': correo,
        'clave':  clave,
        'rol':    'empresa',
        'empresa': {'ruc': ruc, 'razon_social': razonSocial},
      }),
    );
    _parsearRespuesta(res);
  }

  /// Registro de empleado
  Future<void> registrarEmpleado({
    required String correo,
    required String clave,
    required String nombre,
    required String codigo,
    required int empresaId,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/auth/registro'),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'correo':     correo,
        'clave':      clave,
        'rol':        'empleado',
        'empresa_id': empresaId,
        'empleado':   {'nombre': nombre, 'codigo': codigo},
      }),
    );
    _parsearRespuesta(res);
  }

  Future<void> logout() async {
    await borrarToken();
  }

  // ════════════════════════════════════════════════════════════
  // OBRAS
  // ════════════════════════════════════════════════════════════

  Future<List<dynamic>> obtenerObras() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/obras'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> crearObra({
    required String nombre,
    required String descripcion,
    required double latitud,
    required double longitud,
    required double radioMetros,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/obras'),
      headers: await _headers(),
      body: jsonEncode({
        'nombre':               nombre,
        'descripcion_ubicacion': descripcion,
        'latitud':              latitud,
        'longitud':             longitud,
        'radio_metros':         radioMetros,
      }),
    );
    return _parsearRespuesta(res);
  }

  Future<List<dynamic>> obtenerSolicitudesObra(int obraId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/obras/$obraId/solicitudes'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<void> responderSolicitud(int obraId, int solicitudId, String estado) async {
    final res = await _client.patch(
      Uri.parse('$kBaseUrl/obras/$obraId/solicitudes/$solicitudId'),
      headers: await _headers(),
      body: jsonEncode({'estado': estado}),
    );
    _parsearRespuesta(res);
  }

  // ════════════════════════════════════════════════════════════
  // ASISTENCIAS
  // ════════════════════════════════════════════════════════════

  /// Marcar entrada o salida (el backend decide cuál según estado del día)
  Future<Map<String, dynamic>> marcarAsistencia({
    required int obraId,
    required double latitud,
    required double longitud,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/asistencias/marcar'),
      headers: await _headers(),
      body: jsonEncode({
        'obra_id':  obraId,
        'latitud':  latitud,
        'longitud': longitud,
      }),
    );
    return _parsearRespuesta(res);
  }

  /// Historial del empleado autenticado
  Future<List<dynamic>> obtenerHistorial() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/asistencias/historial'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// Ver asistencias de la empresa (con filtros opcionales)
  Future<List<dynamic>> obtenerAsistenciasEmpresa({
    int? obraId,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    final params = <String, String>{};
    if (obraId != null)      params['obra_id']      = obraId.toString();
    if (fechaInicio != null) params['fecha_inicio']  = fechaInicio;
    if (fechaFin != null)    params['fecha_fin']     = fechaFin;

    final uri = Uri.parse('$kBaseUrl/asistencias').replace(queryParameters: params);
    final res  = await _client.get(uri, headers: await _headers());
    return jsonDecode(res.body) as List<dynamic>;
  }

  // ════════════════════════════════════════════════════════════
  // EMPLEADOS
  // ════════════════════════════════════════════════════════════

  Future<List<dynamic>> obtenerEmpleados() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/empleados'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<void> solicitarIngreso(int obraId) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/empleados/solicitar_obra'),
      headers: await _headers(),
      body: jsonEncode({'obra_id': obraId}),
    );
    _parsearRespuesta(res);
  }

  // ════════════════════════════════════════════════════════════
  // PAGOS
  // ════════════════════════════════════════════════════════════

  Future<List<dynamic>> obtenerPagos() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/pagos'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> crearPago({
    required String fechaPago,
    required String tipoPago,
    required List<Map<String, dynamic>> empleados,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/pagos'),
      headers: await _headers(),
      body: jsonEncode({
        'fecha_pago': fechaPago,
        'tipo_pago':  tipoPago,
        'empleados':  empleados,
      }),
    );
    return _parsearRespuesta(res);
  }

  // ════════════════════════════════════════════════════════════
  // VALORACIONES
  // ════════════════════════════════════════════════════════════

  Future<void> crearValoracion({
    required int puntaje,
    required String comentario,
    required String evaluadoType,
    required int evaluadoId,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/valoraciones'),
      headers: await _headers(),
      body: jsonEncode({
        'puntaje':       puntaje,
        'comentario':    comentario,
        'evaluado_type': evaluadoType,
        'evaluado_id':   evaluadoId,
      }),
    );
    _parsearRespuesta(res);
  }

  // ════════════════════════════════════════════════════════════
  // SUSCRIPCIÓN
  // ════════════════════════════════════════════════════════════

  Future<List<dynamic>> obtenerPlanes() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/planes'),
      headers: await _headers(auth: false),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> obtenerSuscripcion() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/suscripcion'),
      headers: await _headers(),
    );
    return _parsearRespuesta(res);
  }
}

// ── Modelos de resultado ────────────────────────────────────

class LoginResult {
  const LoginResult({
    required this.token,
    required this.rol,
    required this.perfil,
  });

  final String token;
  final String rol;                      // 'empresa' | 'empleado'
  final Map<String, dynamic> perfil;
}

class ApiException implements Exception {
  const ApiException(this.mensaje, this.statusCode);

  final String mensaje;
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $mensaje';
}

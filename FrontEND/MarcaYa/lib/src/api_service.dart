// lib/src/api_service.dart
// Reemplaza la lógica simulada de MarcaYAState por llamadas HTTP reales

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── CAMBIA ESTA URL SEGÚN DONDE CORRA TU BACKEND ───────────
// Emulador Android:  http://10.0.2.2:3000/api/v1
// Google chrome: http://localhost:3000/api/v1
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

  Future<Map<String, dynamic>> obtenerObra(int obraId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/obras/$obraId'),
      headers: await _headers(),
    );

    return _parsearRespuesta(res);
  }

  Future<Map<String, dynamic>> crearObra({
    required String codigoObra,
    required String nombre,
    required String descripcionUbicacion,
    required double latitud,
    required double longitud,
    required int radioMetros,
    required String horaInicio,
    required String horaFin,
    required String fechaInicio,
    required String fechaFin,
    required int capacidadEmpleados,
    required String direccion,
  }) async {

    final res = await _client.post(
      Uri.parse('$kBaseUrl/obras'),
      headers: await _headers(),
      body: jsonEncode({
        'empresa_id': 1,
        'codigo_obra': codigoObra,
        'nombre': nombre,
        'descripcion_ubicacion': descripcionUbicacion,
        'latitud': latitud,
        'longitud': longitud,
        'radio_metros': radioMetros,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
        'capacidad_empleados': capacidadEmpleados,
        'direccion': direccion,
        'estado': 'activa',
      }),
    );

    return _parsearRespuesta(res);
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
  /// Trae todos los empleados actuales de la empresa
  Future<List<dynamic>> obtenerEmpleadosActuales(String empresaId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/empleados/actuales?empresa_id=$empresaId'),
      headers: await _headers(),
    );

    if (res.statusCode >= 400) {
      throw Exception('Error al obtener empleados actuales');
    }

    final data = jsonDecode(res.body);

    // Si viene un solo Map, lo conviertes a List
    if (data is Map<String, dynamic>) {
      return [data];
    } else if (data is List) {
      return List<dynamic>.from(data);
    } else {
      return [];
    }
  }

  Future<List<dynamic>> obtenerEmpleados() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/empleados'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<List<dynamic>> obtenerUsuarios() async {

    final res = await _client.get(
      Uri.parse('$kBaseUrl/usuarios'),
      headers: await _headers(),
    );

    return jsonDecode(res.body) as List<dynamic>;
  }

  // ════════════════════════════════════════════════════════════
// SOLICITUDES
// ════════════════════════════════════════════════════════════

  /// Trae todas las solicitudes de la empresa autenticada
  Future<List<dynamic>> obtenerSolicitudes() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/solicitudes'),
      headers: await _headers(),
    );

    // Devuelve la lista de solicitudes directamente desde el backend
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// El empleado solicita ingreso a una obra
  Future<void> solicitarIngreso({
    required int obraId,
    required String empleadoId,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/solicitudes'),
      headers: await _headers(),
      body: jsonEncode({
        'obra_id': obraId,
        'empleado_id': empleadoId,
      }),
    );

    _parsearRespuesta(res);
  }

  Future<List<dynamic>> obtenerObrasEmpleado(String empleadoId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/empleados/$empleadoId/obras'),
      headers: await _headers(),
    );

    if (res.statusCode >= 400) {
      throw Exception('Error al obtener obras del empleado');
    }

    return jsonDecode(res.body) as List<dynamic>;
  }

  /// La empresa acepta una solicitud pendiente
  Future<void> aceptarSolicitud(int solicitudId) async {
    final res = await _client.put(
      Uri.parse('$kBaseUrl/solicitudes/$solicitudId/aceptar'),
      headers: await _headers(),
    );

    _parsearRespuesta(res);
  }

  /// La empresa rechaza una solicitud pendiente
  Future<void> rechazarSolicitud(int solicitudId) async {
    final res = await _client.put(
      Uri.parse('$kBaseUrl/solicitudes/$solicitudId/rechazar'),
      headers: await _headers(),
    );

    _parsearRespuesta(res);
  }

  Future<List<dynamic>> obtenerSolicitudesEmpleado(
      String empleadoId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/solicitudes?id=$empleadoId'),
      headers: await _headers(),
    );

    return List<dynamic>.from(
      jsonDecode(res.body),
    );
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
  // PERFIL
  // ════════════════════════════════════════════════════════════

  /// Obtiene el perfil del usuario autenticado desde el backend
  Future<Map<String, dynamic>> obtenerPerfil() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/perfil'),
      headers: await _headers(),
    );
    return _parsearRespuesta(res);
  }

  /// Actualiza nombre y/o correo del perfil autenticado
  Future<Map<String, dynamic>> actualizarPerfil({
    required String nombre,
    required String correo,
  }) async {
    final res = await _client.put(
      Uri.parse('$kBaseUrl/perfil'),
      headers: await _headers(),
      body: jsonEncode({'nombre': nombre, 'correo': correo}),
    );
    return _parsearRespuesta(res);
  }

  Future<Map<String, dynamic>> obtenerPerfilUsuario(int usuarioId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/usuarios/$usuarioId'),
      headers: await _headers(),
    );
    final data = _parsearRespuesta(res);

    // si es empresa, trae info de empresas
    if (data['rol'] == 'empresa') {
      // llamada a /empresas?usuario_id=...
      // o data['empresa'] incluido en el backend
    } else {
      // llamada a /empleados?usuario_id=...
      // o data['empleado'] incluido en el backend
    }

    return data;
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

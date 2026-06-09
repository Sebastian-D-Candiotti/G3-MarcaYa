// lib/src/api_service.dart
// Reemplaza la lógica simulada de MarcaYAState por llamadas HTTP reales

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  ApiService._({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  static final ApiService instance = ApiService._();

  @visibleForTesting
  static ApiService createForTesting({
    required http.Client client,
    FlutterSecureStorage? storage,
  }) {
    return ApiService._(client: client, storage: storage);
  }

  final FlutterSecureStorage _storage;
  final http.Client _client;

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
      final mensaje =
          body['error'] ??
          (body['errors'] is List
              ? (body['errors'] as List).join(', ')
              : null) ??
          body['errors'] ??
          'Error desconocido';
      throw ApiException(mensaje.toString(), res.statusCode);
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
      token: data['token'] as String,
      rol: data['rol'] as String,
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
        'clave': clave,
        'rol': 'empresa',
        'nombre': razonSocial,
        'ruc': ruc,
      }),
    );
    _parsearRespuesta(res);
  }

  /// Consulta RENIEC por DNI
  Future<Map<String, dynamic>> consultarReniec(String dni) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/reniec/$dni'),
      headers: await _headers(auth: false),
    );

    return _parsearRespuesta(res);
  }

  /// Registro de empleado
  Future<Map<String, dynamic>> registrarEmpleado({
    required String correo,
    required String clave,
    required String nombre,
    String? apellido,
    String? dni,
  }) async {
    final body = <String, dynamic>{
      'correo': correo,
      'clave': clave,
      'rol': 'empleado',
      'nombre': nombre,
    };
    if (apellido != null) body['apellido'] = apellido;
    if (dni != null) body['dni'] = dni;

    final res = await _client.post(
      Uri.parse('$kBaseUrl/auth/registro'),
      headers: await _headers(auth: false),
      body: jsonEncode(body),
    );
    return _parsearRespuesta(res);
  }

  Future<void> logout() async {
    await borrarToken();
  }

  // ════════════════════════════════════════════════════════════
  // OBRAS
  // ════════════════════════════════════════════════════════════

  Future<List<dynamic>> obtenerObras({int? empresaId}) async {
    var url = '$kBaseUrl/obras';
    if (empresaId != null) {
      url = '$url?empresa_id=$empresaId';
    }
    final res = await _client.get(Uri.parse(url), headers: await _headers());

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
    String? direccion,
  }) async {
    final body = <String, dynamic>{
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
      'estado': 'activa',
    };
    if (direccion != null) body['direccion'] = direccion;

    final res = await _client.post(
      Uri.parse('$kBaseUrl/obras'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _parsearRespuesta(res);
  }

  // ═══════════════════════════════════════════════════════════════
  // PARADAS (US-0001-0002)
  // ═══════════════════════════════════════════════════════════════

  Future<List<dynamic>> obtenerParadas(int obraId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/obras/$obraId/paradas'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> crearParada({
    required int obraId,
    required String nombre,
    required double latitud,
    required double longitud,
    required double radioMetros,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/obras/$obraId/paradas'),
      headers: await _headers(),
      body: jsonEncode({
        'nombre': nombre,
        'latitud': latitud,
        'longitud': longitud,
        'radio_metros': radioMetros,
      }),
    );
    return _parsearRespuesta(res);
  }

  Future<Map<String, dynamic>> obtenerParada(int paradaId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/paradas/$paradaId'),
      headers: await _headers(),
    );
    return _parsearRespuesta(res);
  }

  Future<Map<String, dynamic>> actualizarParada(
    int paradaId, {
    String? nombre,
    double? latitud,
    double? longitud,
    double? radioMetros,
  }) async {
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (latitud != null) body['latitud'] = latitud;
    if (longitud != null) body['longitud'] = longitud;
    if (radioMetros != null) body['radio_metros'] = radioMetros;

    final res = await _client.put(
      Uri.parse('$kBaseUrl/paradas/$paradaId'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _parsearRespuesta(res);
  }

  Future<void> eliminarParada(int paradaId) async {
    final res = await _client.delete(
      Uri.parse('$kBaseUrl/paradas/$paradaId'),
      headers: await _headers(),
    );
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw ApiException(
        body['error'] ?? 'Error al eliminar parada',
        res.statusCode,
      );
    }
  }

  /// Asigna un empleado a una parada (POST /api/v1/paradas/:id/empleados)
  Future<void> asignarEmpleadoAParada({
    required int paradaId,
    required int empleadoId,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/paradas/$paradaId/empleados'),
      headers: await _headers(),
      body: jsonEncode({'empleado_id': empleadoId}),
    );
    _parsearRespuesta(res);
  }

  // ════════════════════════════════════════════════════════════
  // ASISTENCIAS
  // ════════════════════════════════════════════════════════════

  /// Marcar entrada (US-0001-0003)
  Future<Map<String, dynamic>> marcarEntrada({
    required int paradaId,
    required double latitud,
    required double longitud,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/asistencia/marcar-entrada'),
      headers: await _headers(),
      body: jsonEncode({
        'parada_id': paradaId,
        'latitud': latitud,
        'longitud': longitud,
      }),
    );
    return _parsearRespuesta(res);
  }

  /// Marcar salida (US-0001-0004)
  Future<Map<String, dynamic>> marcarSalida({
    required int paradaId,
    required double latitud,
    required double longitud,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/asistencia/marcar-salida'),
      headers: await _headers(),
      body: jsonEncode({
        'parada_id': paradaId,
        'latitud': latitud,
        'longitud': longitud,
      }),
    );
    return _parsearRespuesta(res);
  }

  /// Historial del empleado autenticado (US-0001-0008)
  Future<List<dynamic>> obtenerHistorial() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/asistencia/historial'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// Asistencia en tiempo real para una parada específica
  Future<List<dynamic>> obtenerAsistenciaTiempoReal(int paradaId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/asistencia/tiempo-real/$paradaId'),
      headers: await _headers(),
    );

    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      final mensaje = body is Map
          ? (body['error'] ?? body['errors'] ?? 'Error al cargar asistencia')
          : 'Error al cargar asistencia';
      throw ApiException(mensaje.toString(), res.statusCode);
    }

    final body = jsonDecode(res.body);
    if (body is List) return body;
    if (body is Map && body.containsKey('error')) {
      throw ApiException(body['error'].toString(), res.statusCode);
    }
    return [];
  }

  // ════════════════════════════════════════════════════════════
  // EMPLEADOS
  // ════════════════════════════════════════════════════════════

  /// Trae todos los empleados actuales de la empresa autenticada (US-0001-0005)
  Future<List<dynamic>> obtenerEmpleadosActuales() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/empleados/actuales'),
      headers: await _headers(),
    );

    if (res.statusCode >= 400) {
      throw ApiException('Error al obtener empleados actuales', res.statusCode);
    }

    final data = jsonDecode(res.body);

    if (data is List) {
      return List<dynamic>.from(data);
    } else if (data is Map<String, dynamic>) {
      return [data];
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

  Future<Map<String, dynamic>> actualizarEmpleado(
    int empleadoId, {
    String? nombre,
    String? codigo,
  }) async {
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (codigo != null) body['codigo'] = codigo;

    final res = await _client.put(
      Uri.parse('$kBaseUrl/empleados/$empleadoId'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _parsearRespuesta(res);
  }

  Future<void> desactivarEmpleado(int empleadoId) async {
    final res = await _client.put(
      Uri.parse('$kBaseUrl/empleados/$empleadoId/desactivar'),
      headers: await _headers(),
    );
    _parsearRespuesta(res);
  }

  Future<List<dynamic>> obtenerAsistenciasEmpleado(int empleadoId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/asistencia/historial/$empleadoId'),
      headers: await _headers(),
    );

    if (res.statusCode >= 400) {
      throw ApiException(
        'Error al obtener asistencias del empleado',
        res.statusCode,
      );
    }

    final body = jsonDecode(res.body);
    if (body is List) return body;
    return [];
  }

  Future<List<dynamic>> obtenerParadasEmpleado(int empleadoId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/empleados/$empleadoId/paradas'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<List<dynamic>> obtenerObrasEmpleado(String empleadoId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/empleados/$empleadoId/obras'),
      headers: await _headers(),
    );

    if (res.statusCode >= 400) {
      throw ApiException('Error al obtener obras del empleado', res.statusCode);
    }

    final body = jsonDecode(res.body);
    if (body is List) return body;
    return [];
  }

  Future<List<dynamic>> obtenerUsuarios() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/usuarios'),
      headers: await _headers(),
    );

    return jsonDecode(res.body) as List<dynamic>;
  }

  // ════════════════════════════════════════════════════════════
  // PERFIL (US-0001-0006)
  // ════════════════════════════════════════════════════════════

  /// Obtiene perfil de un usuario específico por ID
  Future<Map<String, dynamic>> obtenerPerfil(int usuarioId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/usuarios/$usuarioId'),
      headers: await _headers(),
    );
    return _parsearRespuesta(res);
  }

  /// Actualiza datos del perfil de un usuario
  Future<Map<String, dynamic>> actualizarPerfil(
    int usuarioId, {
    String? correo,
    String? nombre,
    String? apellido,
  }) async {
    final body = <String, dynamic>{};
    if (correo != null) body['correo'] = correo;
    if (nombre != null) body['nombre'] = nombre;
    if (apellido != null) body['apellido'] = apellido;

    final res = await _client.put(
      Uri.parse('$kBaseUrl/usuarios/$usuarioId'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _parsearRespuesta(res);
  }

  /// Actualiza el perfil del usuario autenticado vía PUT /api/v1/perfil
  /// Acepta campos tanto de empleado como de empresa según el rol
  Future<Map<String, dynamic>> actualizarMiPerfil({
    String? correo,
    String? nombre,
    String? apellido,
    String? telefono,
    String? descripcion,
    String? nombreEmpresa,
    String? direccion,
    String? ruc,
  }) async {
    final body = <String, dynamic>{};
    if (correo != null) body['correo'] = correo;
    if (nombre != null) body['nombre'] = nombre;
    if (apellido != null) body['apellido'] = apellido;
    if (telefono != null) body['telefono'] = telefono;
    if (descripcion != null) body['descripcion'] = descripcion;
    if (nombreEmpresa != null) body['nombre_empresa'] = nombreEmpresa;
    if (direccion != null) body['direccion'] = direccion;
    if (ruc != null) body['ruc'] = ruc;

    final res = await _client.put(
      Uri.parse('$kBaseUrl/perfil'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _parsearRespuesta(res);
  }

  /// Obtiene el perfil del usuario autenticado (nuevo endpoint del backend)
  Future<Map<String, dynamic>> obtenerMiPerfil() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/perfil'),
      headers: await _headers(),
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
  // SOLICITUDES (US-0001-0007, US-0001-0008)
  // ════════════════════════════════════════════════════════════

  /// Trae todas las solicitudes de la empresa autenticada
  Future<List<dynamic>> obtenerSolicitudes() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/solicitudes'),
      headers: await _headers(),
    );

    return jsonDecode(res.body) as List<dynamic>;
  }

  /// El empleado solicita ingreso a una empresa
  Future<void> solicitarIngreso({
    required int empleadoId,
    required int empresaId,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/solicitudes'),
      headers: await _headers(),
      body: jsonEncode({'empleado_id': empleadoId, 'empresa_id': empresaId}),
    );

    _parsearRespuesta(res);
  }

  /// Obtiene el historial de solicitudes de un empleado
  Future<List<dynamic>> obtenerSolicitudesEmpleado(String empleadoId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/empleados/$empleadoId/historial_solicitudes'),
      headers: await _headers(),
    );

    return List<dynamic>.from(jsonDecode(res.body));
  }

  /// Obtiene las solicitudes del empleado autenticado
  Future<List<dynamic>> obtenerMisSolicitudes() async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/solicitudes/mis-solicitudes'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// Obtiene una solicitud específica por ID
  Future<Map<String, dynamic>> obtenerSolicitud(int solicitudId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/solicitudes/$solicitudId'),
      headers: await _headers(),
    );
    return _parsearRespuesta(res);
  }

  /// La empresa acepta una solicitud pendiente
  Future<void> aceptarSolicitud(int solicitudId, {required int obraId}) async {
    final res = await _client.put(
      Uri.parse('$kBaseUrl/solicitudes/$solicitudId/aceptar'),
      headers: await _headers(),
      body: jsonEncode({'obra_id': obraId}),
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

  // ════════════════════════════════════════════════════════════
  // VALORACIONES
  // ════════════════════════════════════════════════════════════

  Future<void> crearValoracion({
    required int empresaId,
    required int puntuacion,
    required String comentario,
  }) async {
    final res = await _client.post(
      Uri.parse('$kBaseUrl/valoraciones'),
      headers: await _headers(),
      body: jsonEncode({
        'empresa_id': empresaId,
        'puntuacion': puntuacion,
        'comentario': comentario,
      }),
    );
    _parsearRespuesta(res);
  }

  // ════════════════════════════════════════════════════════════
  // REPORTES (US-0001-0009)
  // ════════════════════════════════════════════════════════════

  Future<List<dynamic>> obtenerReporteAsistencia({
    String? fechaInicio,
    String? fechaFin,
    int? empleadoId,
    int? paradaId,
    int? obraId,
  }) async {
    final params = <String, String>{};
    if (fechaInicio != null) params['fecha_inicio'] = fechaInicio;
    if (fechaFin != null) params['fecha_fin'] = fechaFin;
    if (empleadoId != null) params['empleado_id'] = empleadoId.toString();
    if (paradaId != null) params['parada_id'] = paradaId.toString();
    if (obraId != null) params['obra_id'] = obraId.toString();

    final uri = Uri.parse(
      '$kBaseUrl/reportes/asistencia',
    ).replace(queryParameters: params.isNotEmpty ? params : null);
    final res = await _client.get(uri, headers: await _headers());
    return jsonDecode(res.body) as List<dynamic>;
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
  final String rol; // 'empresa' | 'empleado'
  final Map<String, dynamic> perfil;
}

class ApiException implements Exception {
  const ApiException(this.mensaje, this.statusCode);

  final String mensaje;
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $mensaje';
}

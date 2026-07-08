import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DashboardProvider extends ChangeNotifier {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  static const storage = FlutterSecureStorage();

  Map<String, dynamic>? _estadisticas;
  List<dynamic> _obras = [];
  dynamic _obraSeleccionada;
  bool _isLoading = false;
  String? _error;
  String _periodo = '';

  // Getters
  Map<String, dynamic>? get estadisticas => _estadisticas;
  List<dynamic> get obras => _obras;
  dynamic get obraSeleccionada => _obraSeleccionada;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get periodo => _periodo;

  DashboardProvider() {
    _inicializarPeriodo();
  }

  void _inicializarPeriodo() {
    final ahora = DateTime.now();
    _periodo = '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}';
  }

  Future<void> cargarEstadisticas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await storage.read(key: 'jwt_token');
      
      if (token == null) {
        _error = 'No autenticado';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Obtener obras primero
      await _cargarObras(token);

      // Cargar estadísticas
      final url = _obraSeleccionada != null
          ? '$baseUrl/estadisticas/obra/${_obraSeleccionada['id']}?periodo=$_periodo'
          : '$baseUrl/estadisticas/resumen?periodo=$_periodo';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Extraer datos dependiendo del formato de respuesta
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          _estadisticas = jsonResponse['data'];
        } else if (jsonResponse is Map && jsonResponse.containsKey('estadisticas')) {
          _estadisticas = jsonResponse['estadisticas'];
        } else {
          _estadisticas = jsonResponse;
        }
        
        _error = null;
      } else if (response.statusCode == 401) {
        _error = 'Sesión expirada';
      } else if (response.statusCode == 403) {
        _error = 'No tienes permisos para ver esta información';
      } else {
        _error = 'Error al cargar estadísticas: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
      _estadisticas = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _cargarObras(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/obras'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          _obras = jsonResponse['data'] ?? [];
        } else if (jsonResponse is List) {
          _obras = jsonResponse;
        } else {
          _obras = [];
        }
      }
    } catch (e) {
      // Silenciar errores al cargar obras, no es crítico
      _obras = [];
    }
  }

  void seleccionarObra(dynamic obra) {
    _obraSeleccionada = obra;
    cargarEstadisticas();
  }

  void cambiarPeriodo(String nuevoPeriodo) {
    _periodo = nuevoPeriodo;
    cargarEstadisticas();
  }

  void reintentar() {
    cargarEstadisticas();
  }
}
